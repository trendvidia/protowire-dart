import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';

bool isTimestamp(BuilderInfo info) {
  return info.qualifiedMessageName == 'google.protobuf.Timestamp';
}

bool isDuration(BuilderInfo info) {
  return info.qualifiedMessageName == 'google.protobuf.Duration';
}

bool isAny(BuilderInfo info) {
  return info.qualifiedMessageName == 'google.protobuf.Any';
}

void setTimestampFields(GeneratedMessage msg, DateTime t) {
  // Use tag numbers instead of names because GeneratedMessage works better with tags
  // seconds = 1, nanos = 2
  msg.setField(1, Int64(t.millisecondsSinceEpoch ~/ 1000));
  msg.setField(2, (t.millisecondsSinceEpoch % 1000) * 1000000);
}

void setDurationFields(GeneratedMessage msg, Duration dur) {
  // seconds = 1, nanos = 2
  int microseconds = dur.inMicroseconds;
  int seconds = microseconds ~/ 1000000;
  int nanos = (microseconds % 1000000) * 1000;
  msg.setField(1, Int64(seconds));
  msg.setField(2, nanos);
}

DateTime readTimestamp(GeneratedMessage msg) {
  Int64 seconds = msg.getField(1);
  int nanos = msg.getField(2);
  return DateTime.fromMillisecondsSinceEpoch(
    seconds.toInt() * 1000 + nanos ~/ 1000000,
    isUtc: true,
  );
}

Duration readDuration(GeneratedMessage msg) {
  Int64 seconds = msg.getField(1);
  int nanos = msg.getField(2);
  return Duration(
    seconds: seconds.toInt(),
    microseconds: nanos ~/ 1000,
  );
}

// Wrapper type check
final Set<String> wrapperTypes = {
  'google.protobuf.BoolValue',
  'google.protobuf.BytesValue',
  'google.protobuf.DoubleValue',
  'google.protobuf.FloatValue',
  'google.protobuf.Int32Value',
  'google.protobuf.Int64Value',
  'google.protobuf.StringValue',
  'google.protobuf.UInt32Value',
  'google.protobuf.UInt64Value',
};

bool isWrapperType(BuilderInfo info) {
  return wrapperTypes.contains(info.qualifiedMessageName);
}
