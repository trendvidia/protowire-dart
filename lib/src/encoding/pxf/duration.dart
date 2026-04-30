Duration parseGoDuration(String s) {
  if (s == '0' || s == '+0' || s == '-0') return Duration.zero;

  final regex = RegExp(r'([-+]?)([0-9.]+(?:ns|us|µs|ms|s|m|h))');
  final matches = regex.allMatches(s);
  if (matches.isEmpty) throw FormatException('Invalid duration: $s');

  bool negative = s.startsWith('-');
  int totalMicroseconds = 0;

  for (var match in matches) {
    String part = match.group(2)!;
    if (part.endsWith('ns')) {
      // Dart Duration doesn't support nanoseconds, we'll lose precision or round.
      // 1000ns = 1us
      double ns = double.parse(part.substring(0, part.length - 2));
      totalMicroseconds += (ns / 1000).round();
    } else if (part.endsWith('us')) {
      totalMicroseconds += double.parse(part.substring(0, part.length - 2)).round();
    } else if (part.endsWith('µs')) {
      totalMicroseconds += double.parse(part.substring(0, part.length - 2)).round();
    } else if (part.endsWith('ms')) {
      totalMicroseconds += (double.parse(part.substring(0, part.length - 2)) * 1000).round();
    } else if (part.endsWith('s')) {
      totalMicroseconds += (double.parse(part.substring(0, part.length - 1)) * 1000000).round();
    } else if (part.endsWith('m')) {
      totalMicroseconds += (double.parse(part.substring(0, part.length - 1)) * 60000000).round();
    } else if (part.endsWith('h')) {
      totalMicroseconds += (double.parse(part.substring(0, part.length - 1)) * 3600000000).round();
    }
  }

  return Duration(microseconds: negative ? -totalMicroseconds : totalMicroseconds);
}
