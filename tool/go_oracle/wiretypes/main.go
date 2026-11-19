// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.

// wiretypes writes what protobuf-go does with a record of every wire type on
// every field of test/testdata/wire-types, so that
// test/pb_wire_type_test.dart can hold this port to it (protowire#614).
//
//	go run ./wiretypes -dir ../../test/testdata/wire-types -out ../../test/testdata/wire-types/oracle.json
//
// The inputs for conf.All are protowire-go's (encoding/pb/wire_type_test.go,
// protowire-go#308): every field gets one record of every wire type, well
// formed and cut short, alone and inside each message and map field, plus
// four inputs where a matching record follows a mismatched one. ext.proto's
// Base adds an enum, a group and extensions, which conf.proto cannot hold.
package main

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"flag"
	"log"
	"os"

	"github.com/trendvidia/protocompile"
	"google.golang.org/protobuf/encoding/protowire"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/reflect/protoregistry"
	"google.golang.org/protobuf/types/dynamicpb"
)

// row is protobuf-go's verdict on one input. Known is the message it read,
// without its unknown fields, and All the message with them, each written
// deterministically; both are absent on a rejection.
type row struct {
	Message  string `json:"message"`
	Input    string `json:"input"`
	Accepted bool   `json:"accepted"`
	Error    string `json:"error,omitempty"`
	Known    string `json:"known,omitempty"`
	All      string `json:"all,omitempty"`
}

func main() {
	dir := flag.String("dir", "", "test/testdata/wire-types")
	out := flag.String("out", "", "file to write")
	flag.Parse()

	compiler := protocompile.Compiler{
		Resolver: protocompile.WithStandardImports(&protocompile.SourceResolver{
			ImportPaths: []string{*dir},
		}),
	}
	files, err := compiler.Compile(context.Background(), "conf.proto", "ext.proto")
	if err != nil {
		log.Fatal(err)
	}
	reg := new(protoregistry.Files)
	for _, f := range files {
		if err := reg.RegisterFile(f); err != nil {
			log.Fatal(err)
		}
	}
	types := dynamicpb.NewTypes(reg)

	var rows []row
	add := func(name string, inputs [][]byte) {
		d, err := reg.FindDescriptorByName(protoreflect.FullName(name))
		if err != nil {
			log.Fatal(err)
		}
		md := d.(protoreflect.MessageDescriptor)
		for _, in := range inputs {
			rows = append(rows, verdict(md, types, in))
		}
	}
	add("conf.All", confInputs())
	add("wiretypes.v1.Base", baseInputs())

	b, err := json.MarshalIndent(rows, "", " ")
	if err != nil {
		log.Fatal(err)
	}
	if err := os.WriteFile(*out, append(b, '\n'), 0o644); err != nil {
		log.Fatal(err)
	}
	accepted := 0
	for _, r := range rows {
		if r.Accepted {
			accepted++
		}
	}
	log.Printf("%d inputs: protobuf-go accepts %d, rejects %d", len(rows), accepted, len(rows)-accepted)
}

func verdict(md protoreflect.MessageDescriptor, types *dynamicpb.Types, in []byte) row {
	r := row{Message: string(md.FullName()), Input: hex.EncodeToString(in)}
	all := dynamicpb.NewMessage(md)
	if err := (proto.UnmarshalOptions{Resolver: types}).Unmarshal(in, all); err != nil {
		r.Error = err.Error()
		return r
	}
	known := dynamicpb.NewMessage(md)
	if err := (proto.UnmarshalOptions{Resolver: types, DiscardUnknown: true}).Unmarshal(in, known); err != nil {
		log.Fatalf("%x: accepted, then rejected without unknown fields: %v", in, err)
	}
	r.Accepted = true
	r.Known = hex.EncodeToString(marshal(known))
	r.All = hex.EncodeToString(marshal(all))
	return r
}

func marshal(m proto.Message) []byte {
	b, err := proto.MarshalOptions{Deterministic: true}.Marshal(m)
	if err != nil {
		log.Fatal(err)
	}
	return b
}

// records returns single records for field num: every wire type, each with a
// well-formed value and a value cut short. protowire-go's wireRecords.
func records(num protowire.Number) [][]byte {
	tag := func(typ protowire.Type) []byte { return protowire.AppendTag(nil, num, typ) }
	cat := func(parts ...[]byte) []byte {
		var b []byte
		for _, p := range parts {
			b = append(b, p...)
		}
		return b
	}
	return [][]byte{
		cat(tag(protowire.VarintType), []byte{0x01}),
		cat(tag(protowire.VarintType), []byte{0x80}), // cut short
		cat(tag(protowire.Fixed64Type), []byte{1, 0, 0, 0, 0, 0, 0, 0}),
		cat(tag(protowire.Fixed64Type), []byte{1, 0, 0}), // cut short
		cat(tag(protowire.BytesType), []byte{0x00}),
		cat(tag(protowire.BytesType), []byte{0x01, 0x01}),
		cat(tag(protowire.BytesType), []byte{0x01}), // cut short
		cat(tag(protowire.StartGroupType), tag(protowire.EndGroupType)),
		tag(protowire.StartGroupType), // never ended
		tag(protowire.EndGroupType),   // ends nothing
		cat(tag(protowire.Fixed32Type), []byte{1, 0, 0, 0}),
		cat(tag(protowire.Fixed32Type), []byte{1, 0}), // cut short
		cat(protowire.AppendVarint(nil, uint64(num)<<3|6), []byte{0x01}),
		cat(protowire.AppendVarint(nil, uint64(num)<<3|7), []byte{0x01}),
	}
}

func lengthDelimited(outer protowire.Number, rec []byte) []byte {
	b := protowire.AppendTag(nil, outer, protowire.BytesType)
	return protowire.AppendBytes(b, rec)
}

// confInputs is protowire-go's wireTypeInputs: every record for every field
// of conf.All, alone and carried inside each message field (12, 13, 22:
// Inner's fields 1, 2 and an unknown 3) and map field (18, 19, 25: key 1,
// value 2, unknown 3).
func confInputs() [][]byte {
	var out [][]byte
	for num := protowire.Number(1); num <= 25; num++ {
		out = append(out, records(num)...)
	}
	for _, outer := range []protowire.Number{12, 13, 18, 19, 22, 25} {
		for inner := protowire.Number(1); inner <= 3; inner++ {
			for _, rec := range records(inner) {
				out = append(out, lengthDelimited(outer, rec))
			}
		}
	}
	// A matching record after a mismatched one: the mismatch leaves the
	// field as it was, and the match still sets it.
	for _, h := range []string{
		"0a0161" + "0801",     // s: "a", then s as a varint
		"1007" + "1501000000", // i64: 7, then i64 as fixed32
		"720101" + "7001",     // nums packed [1], then nums as a varint
		"7001" + "7501000000", // nums [1], then nums as fixed32
	} {
		b, err := hex.DecodeString(h)
		if err != nil {
			log.Fatal(err)
		}
		out = append(out, b)
	}
	return out
}

// baseInputs does the same for wiretypes.v1.Base: its fields 1, 2, 3, 5 and
// 7, its extensions 100 to 102 and an unknown 6, alone; Base's fields 1 to 6
// inside group 3 and inside extensions 101 and 102, with group 3's own field
// 4 among them; and key 1, value 2 and an unknown 3 inside map field 7.
func baseInputs() [][]byte {
	var out [][]byte
	for _, num := range []protowire.Number{1, 2, 3, 4, 5, 6, 7, 100, 101, 102} {
		out = append(out, records(num)...)
	}
	for inner := protowire.Number(1); inner <= 6; inner++ {
		for _, rec := range records(inner) {
			b := protowire.AppendTag(nil, 3, protowire.StartGroupType)
			b = append(b, rec...)
			out = append(out, protowire.AppendTag(b, 3, protowire.EndGroupType))
		}
	}
	for _, outer := range []protowire.Number{101, 102} {
		for inner := protowire.Number(1); inner <= 6; inner++ {
			for _, rec := range records(inner) {
				out = append(out, lengthDelimited(outer, rec))
			}
		}
	}
	for inner := protowire.Number(1); inner <= 3; inner++ {
		for _, rec := range records(inner) {
			out = append(out, lengthDelimited(7, rec))
		}
	}
	return out
}
