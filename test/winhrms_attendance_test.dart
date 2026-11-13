import 'package:attendance/core/apis/repository/attendance_repo.dart';
import 'package:attendance/core/apis/repository/models/attendance_status.dart';
import 'package:attendance/ui/screens/main_screen/home/bloc/home_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _record({
  bool inn = true,
  bool out = false,
  bool onBreak = false,
  int elapsed = 100,
}) =>
    {
      "attendance_date": "2026-11-13",
      "is_punched_in": inn,
      "is_punched_out": out,
      "is_on_break": onBreak,
      "punch_in_at": inn ? "2026-11-13T03:30:00Z" : null,
      "punch_out_at": out ? "2026-11-13T12:30:00Z" : null,
      "break_started_at": onBreak ? "2026-11-13T07:00:00Z" : null,
      "break_seconds": 0,
      "total_hours": out ? 9.0 : null,
      "elapsed_seconds": elapsed,
      "server_time": "2026-11-13T07:00:00Z",
    };

void main() {
  test('PunchResult parses message and record', () {
    final r = PunchResult.fromJson(
        {"message": "Punched in", "record": _record()});
    expect(r.message, "Punched in");
    expect(r.record.isWorking, isTrue);
  });

  group('HomeLoadedState.workedSecondsAt', () {
    final t0 = DateTime(2026, 11, 13, 12);

    test('ticks while working', () {
      final s = HomeLoadedState(
          today: AttendanceStatus.fromJson(_record()), loadedAt: t0);
      expect(s.workedSecondsAt(t0.add(const Duration(seconds: 30))), 130);
    });

    test('frozen on break', () {
      final s = HomeLoadedState(
          today: AttendanceStatus.fromJson(_record(onBreak: true)),
          loadedAt: t0);
      expect(s.workedSecondsAt(t0.add(const Duration(minutes: 5))), 100);
    });

    test('frozen after punch-out', () {
      final s = HomeLoadedState(
          today: AttendanceStatus.fromJson(_record(out: true, elapsed: 32400)),
          loadedAt: t0);
      expect(s.workedSecondsAt(t0.add(const Duration(hours: 1))), 32400);
    });

    test('zero without data', () {
      expect(const HomeLoadedState().workedSecondsAt(t0), 0);
    });
  });
}
