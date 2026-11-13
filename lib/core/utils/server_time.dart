/// WinHRMS sends attendance timestamps as IST wall-clock time without an
/// offset (e.g. `2026-11-13T20:01:30.667339`), while `server_time` carries
/// `+05:30`. Parse both into the correct instant so phones outside IST don't
/// shift punch times.
class ServerTime {
  ServerTime._();

  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  static final RegExp _hasOffset = RegExp(r'(Z|[+-]\d{2}:?\d{2})$');

  /// Parses a WinHRMS date-time. Naive values are treated as IST.
  /// Returns a UTC [DateTime], or null if [value] is empty or invalid.
  static DateTime? parse(Object? value) {
    if (value == null) return null;
    final String s = value.toString().trim();
    if (s.isEmpty) return null;
    final DateTime? d = DateTime.tryParse(s);
    if (d == null) return null;
    if (_hasOffset.hasMatch(s)) return d.toUtc();
    // Naive → IST wall clock → UTC instant.
    return DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second,
            d.millisecond, d.microsecond)
        .subtract(istOffset);
  }

  /// [instant] shown as IST wall-clock time (what the office sees),
  /// regardless of the phone's timezone.
  static DateTime toIst(DateTime instant) {
    final DateTime u = instant.toUtc().add(istOffset);
    return DateTime(u.year, u.month, u.day, u.hour, u.minute, u.second);
  }

  /// "HH:MM" in IST, the format the correction API expects.
  static String istHhMm(DateTime instant) {
    final DateTime t = toIst(instant);
    return "${t.hour.toString().padLeft(2, '0')}:"
        "${t.minute.toString().padLeft(2, '0')}";
  }

  /// Parses a date-only value (`2026-11-13`) into a local midnight date.
  static DateTime? parseDate(Object? value) {
    final DateTime? d = DateTime.tryParse(value?.toString() ?? "");
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  /// `yyyy-MM-dd` for a calendar date.
  static String dateKey(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
      "${d.month.toString().padLeft(2, '0')}-"
      "${d.day.toString().padLeft(2, '0')}";
}
