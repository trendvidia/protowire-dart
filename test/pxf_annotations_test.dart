import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/test_fixtures/annotated.pb.dart';
import 'package:protowire/src/generated/proto/test_fixtures/annotated.pbjson.dart';

PxfAnnotations _registry() {
  return PxfAnnotations()
    ..register(Config.getDefault().info_, configDescriptor)
    ..register(Endpoint.getDefault().info_, endpointDescriptor);
}

void main() {
  group('(pxf.required) enforcement', () {
    test('decode succeeds when required field is present', () {
      final cfg = Config();
      unmarshal(
        'name = "alice"\n',
        cfg,
        options: UnmarshalOptions(annotations: _registry()),
      );
      expect(cfg.name, 'alice');
    });

    test('decode fails when required root field is absent', () {
      final cfg = Config();
      expect(
        () => unmarshal(
          'role = "admin"\n',
          cfg,
          options: UnmarshalOptions(annotations: _registry()),
        ),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('required field "name"'),
        )),
      );
    });

    test('decode fails when required nested field is absent', () {
      final cfg = Config();
      expect(
        () => unmarshal(
          'name = "alice"\nendpoint { port = 9090 }\n',
          cfg,
          options: UnmarshalOptions(annotations: _registry()),
        ),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('required field "endpoint.host"'),
        )),
      );
    });

    test('plain unmarshal (no annotations) does not enforce required',
        () {
      final cfg = Config();
      // No annotations registry → behaves like a permissive decode.
      unmarshal('role = "admin"\n', cfg);
      expect(cfg.hasName(), false);
    });
  });

  group('(pxf.default) application', () {
    test('absent fields pick up their declared defaults', () {
      final cfg = Config();
      unmarshal(
        'name = "alice"\n',
        cfg,
        options: UnmarshalOptions(annotations: _registry()),
      );
      expect(cfg.role, 'viewer');
      expect(cfg.priority, 5);
      expect(cfg.enabled, true);
      expect(cfg.weight, 0.75);
      expect(cfg.token, [1, 2, 3]); // base64 "AQID"
      expect(cfg.status, Status.STATUS_ACTIVE);
      // Wrapper-type default flows through the inner scalar.
      expect(cfg.nickname.value, 'anon');
      // Timestamp + Duration defaults are parsed from their PXF literal.
      expect(cfg.createdAt.seconds, Int64(1705314600));
      expect(cfg.timeout.seconds, Int64(30));
    });

    test('present scalar fields keep the user-supplied value', () {
      final cfg = Config();
      unmarshal(
        'name = "alice"\nrole = "admin"\npriority = 1\n',
        cfg,
        options: UnmarshalOptions(annotations: _registry()),
      );
      expect(cfg.role, 'admin');
      expect(cfg.priority, 1);
    });

    test('nested message default applies via recursion', () {
      final cfg = Config();
      unmarshal(
        'name = "alice"\nendpoint { host = "example.com" }\n',
        cfg,
        options: UnmarshalOptions(annotations: _registry()),
      );
      expect(cfg.endpoint.host, 'example.com');
      expect(cfg.endpoint.port, 8080); // default for absent port
    });

    test('unmarshalFull also applies defaults and reports presence', () {
      final cfg = Config();
      final result = unmarshalFull(
        'name = "alice"\n',
        cfg,
        options: UnmarshalOptions(annotations: _registry()),
      );
      expect(result.isSet('name'), true);
      // Defaults are applied but the field is still tracked as absent in
      // the Result — same stance Go takes (Result mirrors what the input
      // text said, not what post-decode synthesised).
      expect(result.isAbsent('role'), true);
      expect(cfg.role, 'viewer');
    });
  });
}
