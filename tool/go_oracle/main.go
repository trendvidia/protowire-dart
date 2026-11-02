// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.

// go_oracle runs protowire-go, the reference, over the spec corpora vendored
// in test/testdata and writes what it did with each document, so that
// test/go_conformance_test.dart can hold this port to the same answers.
//
//	go run . -manifest ../../test/conformance/corpora.json -root ../.. -out oracle.json
package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/trendvidia/protocompile"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protodesc"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/reflect/protoregistry"
	"google.golang.org/protobuf/types/descriptorpb"
	"google.golang.org/protobuf/types/dynamicpb"

	"github.com/trendvidia/protowire-go/encoding/pxf"
)

// corpus is one row of the manifest.
type corpus struct {
	Dir      string            `json:"dir"`
	Protos   []string          `json:"protos"`
	Sets     []string          `json:"descriptorSets"` // compiled, in place of Protos
	Message  string            `json:"message"`
	Messages map[string]string `json:"messages"` // by file name
	Named    []string          `json:"named"`    // a document naming one binds it
	Include  string            `json:"include"`  // another import root, under dir
	Dataset  bool              `json:"dataset"`  // documents of @dataset rows
}

// result is what the reference did with one document. PB and Text are absent
// on a rejection.
type result struct {
	Doc      string `json:"doc"`
	Message  string `json:"message,omitempty"`
	Accepted bool   `json:"accepted"`
	Error    string `json:"error,omitempty"`
	PB       []byte `json:"pb,omitempty"`
	Text     string `json:"text,omitempty"`
	Rows     []row  `json:"rows,omitempty"` // a @dataset document, in place of PB and Text
}

// row is one bound @dataset row.
type row struct {
	Message string `json:"message"`
	PB      []byte `json:"pb,omitempty"`
	Text    string `json:"text,omitempty"`
}

type output struct {
	// Descriptors holds each corpus's FileDescriptorSet, so both sides read
	// the same schema.
	Descriptors map[string][]byte `json:"descriptors"`
	Results     []result          `json:"results"`
}

func main() {
	manifest := flag.String("manifest", "", "corpus manifest")
	root := flag.String("root", "", "the protowire-dart checkout")
	out := flag.String("out", "", "file to write")
	flag.Parse()

	raw, err := os.ReadFile(*manifest)
	if err != nil {
		log.Fatal(err)
	}
	var corpora []corpus
	if err := json.Unmarshal(raw, &corpora); err != nil {
		log.Fatal(err)
	}
	o := output{Descriptors: map[string][]byte{}}
	for _, c := range corpora {
		if err := run(c, *root, &o); err != nil {
			log.Fatalf("%s: %v", c.Dir, err)
		}
	}
	data, err := json.MarshalIndent(o, "", " ")
	if err != nil {
		log.Fatal(err)
	}
	if err := os.WriteFile(*out, data, 0o644); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("go_oracle: %d documents in %d corpora\n", len(o.Results), len(corpora))
}

func run(c corpus, root string, o *output) error {
	dir := filepath.Join(root, "test", c.Dir)
	registry, set, err := schema(c, dir, root)
	if err != nil {
		return err
	}
	if o.Descriptors[c.Dir], err = proto.Marshal(set); err != nil {
		return err
	}

	docs, err := filepath.Glob(filepath.Join(dir, "*.pxf"))
	if err != nil {
		return err
	}
	sort.Strings(docs)
	types := resolver{registry}
	for _, path := range docs {
		data, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		name := filepath.Base(path)
		if c.Dataset {
			r := bindRows(data, registry)
			r.Doc = c.Dir + "/" + name
			o.Results = append(o.Results, r)
			continue
		}
		message := c.message(name, string(data))
		found, err := registry.FindDescriptorByName(protoreflect.FullName(message))
		if err != nil {
			return fmt.Errorf("%s: %v", name, err)
		}
		r := decode(data, found.(protoreflect.MessageDescriptor), types)
		r.Doc, r.Message = c.Dir+"/"+name, message
		o.Results = append(o.Results, r)
	}
	return nil
}

// schema compiles the corpus's protos, or reads its compiled sets: a corpus
// whose schema needs the v1.2 compiler, or a proto not vendored here, has only
// the output.
func schema(c corpus, dir, root string) (*protoregistry.Files, *descriptorpb.FileDescriptorSet, error) {
	if len(c.Sets) > 0 {
		set := &descriptorpb.FileDescriptorSet{}
		seen := map[string]bool{}
		for _, name := range c.Sets {
			raw, err := os.ReadFile(filepath.Join(dir, name))
			if err != nil {
				return nil, nil, err
			}
			one := &descriptorpb.FileDescriptorSet{}
			if err := proto.Unmarshal(raw, one); err != nil {
				return nil, nil, err
			}
			for _, f := range one.File {
				if !seen[f.GetName()] {
					seen[f.GetName()] = true
					set.File = append(set.File, f)
				}
			}
		}
		files, err := protodesc.NewFiles(set)
		return files, set, err
	}
	compiler := protocompile.Compiler{
		Resolver: protocompile.WithStandardImports(&protocompile.SourceResolver{
			ImportPaths: []string{dir, filepath.Join(dir, c.Include), filepath.Join(root, "proto")},
		}),
	}
	compiled, err := compiler.Compile(context.Background(), c.Protos...)
	if err != nil {
		return nil, nil, err
	}
	registry := new(protoregistry.Files)
	set := &descriptorpb.FileDescriptorSet{}
	seen := map[string]bool{}
	var add func(fd protoreflect.FileDescriptor) error
	add = func(fd protoreflect.FileDescriptor) error {
		if seen[fd.Path()] {
			return nil
		}
		seen[fd.Path()] = true
		for i := 0; i < fd.Imports().Len(); i++ {
			if err := add(fd.Imports().Get(i).FileDescriptor); err != nil {
				return err
			}
		}
		set.File = append(set.File, protodesc.ToFileDescriptorProto(fd))
		return registry.RegisterFile(fd)
	}
	for _, f := range compiled {
		if err := add(f); err != nil {
			return nil, nil, err
		}
	}
	return registry, set, nil
}

func (c corpus) message(name, text string) string {
	if m := c.Messages[name]; m != "" {
		return m
	}
	for _, m := range c.Named {
		if strings.Contains(text, m) {
			return m
		}
	}
	return c.Message
}

func decode(data []byte, md protoreflect.MessageDescriptor, types resolver) (r result) {
	// The full path: it alone applies @required and @default.
	msg, _, err := pxf.UnmarshalOptions{TypeResolver: types}.UnmarshalFullDescriptor(data, md)
	if err != nil {
		r.Error = err.Error()
		return r
	}
	r.Accepted = true
	if r.PB, err = (proto.MarshalOptions{Deterministic: true}).Marshal(msg); err != nil {
		r.Error = "pb: " + err.Error()
		return r
	}
	text, err := pxf.MarshalOptions{TypeResolver: types}.Marshal(msg)
	if err != nil {
		r.Error = "marshal: " + err.Error()
		return r
	}
	r.Text = string(text)
	return r
}

// bindRows parses a @dataset document and binds each row to its type.
func bindRows(data []byte, files *protoregistry.Files) (r result) {
	doc, err := pxf.Parse(data)
	if err != nil {
		r.Error = err.Error()
		return r
	}
	for _, ds := range doc.Datasets {
		found, err := files.FindDescriptorByName(protoreflect.FullName(ds.Type))
		if err != nil {
			r.Error = err.Error()
			r.Rows = nil
			return r
		}
		md := found.(protoreflect.MessageDescriptor)
		for _, cells := range ds.Rows {
			msg := dynamicpb.NewMessage(md)
			if err := pxf.BindRow(msg, ds.Columns, cells); err != nil {
				r.Error = err.Error()
				r.Rows = nil
				return r
			}
			b, err := (proto.MarshalOptions{Deterministic: true}).Marshal(msg)
			if err != nil {
				r.Error = "pb: " + err.Error()
				r.Rows = nil
				return r
			}
			text, err := pxf.Marshal(msg)
			if err != nil {
				r.Error = "marshal: " + err.Error()
				r.Rows = nil
				return r
			}
			r.Rows = append(r.Rows, row{ds.Type, b, string(text)})
		}
	}
	r.Accepted = true
	return r
}

// resolver finds an Any's type in the corpus's own schema.
type resolver struct{ files *protoregistry.Files }

func (r resolver) FindMessageByURL(url string) (protoreflect.MessageDescriptor, error) {
	name := url[strings.LastIndex(url, "/")+1:]
	d, err := r.files.FindDescriptorByName(protoreflect.FullName(name))
	if err != nil {
		return nil, err
	}
	md, ok := d.(protoreflect.MessageDescriptor)
	if !ok {
		return nil, fmt.Errorf("%s is not a message", name)
	}
	return md, nil
}
