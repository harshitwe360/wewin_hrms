import 'package:attendance/core/apis/repository/attendance_repo.dart';
import 'package:attendance/core/apis/repository/models/attendance_correction.dart';
import 'package:attendance/core/apis/repository/models/attendance_status.dart';
import 'package:attendance/core/apis/repository/models/monthly_attendance.dart';
import 'package:attendance/core/utils/server_time.dart';
import 'package:attendance/ui/screens/attendance/detail/bloc/calendar_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _day(String date,
        {String? inAt, String? outAt, bool weekOff = false, bool leave = false,
        String? leaveStatus, double? hours}) =>
    {
      "date": date,
      "punch_in_at": inAt,
      "punch_out_at": outAt,
      "total_hours": hours,
      "break_seconds": 0,
      "on_leave": leave,
      "is_lwp": false,
      "leave_status": leaveStatus,
      "shift_label": "General Shift",
      "shift_time_label": "10:00 - 18:00",
      "is_week_off": weekOff,
    };

void main() {
  group('ServerTime (naive = IST)', () {
    test('naive timestamp is IST wall clock', () {
      final t = ServerTime.parse('2026-11-13T20:01:30.667339')!;
      expect(t.isUtc, isTrue);
      expect(t, DateTime.utc(2026, 11, 13, 14, 31, 30, 667, 339));
      expect(ServerTime.istHhMm(t), '20:01');
    });

    test('offset timestamp is respected', () {
      expect(ServerTime.parse('2026-11-13T22:26:56+05:30'),
          DateTime.utc(2026, 11, 13, 16, 56, 56));
      expect(ServerTime.parse('2026-11-13T16:56:56Z'),
          DateTime.utc(2026, 11, 13, 16, 56, 56));
    });

    test('empty / invalid → null', () {
      expect(ServerTime.parse(null), isNull);
      expect(ServerTime.parse(''), isNull);
      expect(ServerTime.parse('nope'), isNull);
    });

    test('today status uses IST parsing too', () {
      final s = AttendanceStatus.fromJson({
        "attendance_date": "2026-11-13",
        "punch_out_at": "2026-11-13T22:08:51.560349",
      });
      expect(ServerTime.istHhMm(s.punchOutAt!), '22:08');
    });
  });

  group('MonthlyAttendance day status', () {
    final today = DateTime(2026, 11, 13);
    final month = MonthlyAttendance.fromJson({
      "user_id": 21,
      "user_name": "Test",
      "month": 11,
      "year": 2026,
      "present_days": 1,
      "total_hours_worked": 10.0,
      "days": [
        _day('2026-11-01', weekOff: true),
        _day('2026-11-02', inAt: '2026-11-02T11:38:02', outAt: '2026-11-02T21:38:02', hours: 10),
        _day('2026-11-03'),
        _day('2026-11-04', leave: true, leaveStatus: 'approved'),
        _day('2026-11-05', leave: true, leaveStatus: 'rejected'),
        _day('2026-11-06'),
        _day('2026-11-13'),
        _day('2026-11-20'),
      ],
    });
    final state = CalendarLoadedState(
      month: DateTime(2026, 11),
      attendance: month,
      holidays: {
        '2026-11-06': Holiday(date: DateTime(2026, 11, 6), name: 'Diwali'),
      },
    );

    test('statuses', () {
      DayStatus s(int d) => state.statusFor(DateTime(2026, 11, d), today: today);
      expect(s(1), DayStatus.weekOff);
      expect(s(2), DayStatus.present);
      expect(s(3), DayStatus.absent);
      expect(s(4), DayStatus.leave);
      expect(s(5), DayStatus.absent, reason: 'rejected leave counts as absent');
      expect(s(6), DayStatus.holiday);
      expect(s(13), DayStatus.noData, reason: 'today is not absent yet');
      expect(s(20), DayStatus.upcoming);
    });

    test('counts for summary', () {
      final c = state.counts(today: today);
      expect(c[DayStatus.present], 1);
      expect(c[DayStatus.absent], 2);
      expect(c[DayStatus.leave], 1);
      expect(c[DayStatus.weekOff], 1);
      expect(c[DayStatus.holiday], 1);
    });

    test('punch times parsed as IST', () {
      final d = state.dayFor(DateTime(2026, 11, 2))!;
      expect(ServerTime.istHhMm(d.punchInAt!), '11:38');
      expect(d.totalHours, 10);
    });
  });

  group('Corrections', () {
    test('request body matches the web app', () {
      expect(
        AttendanceRepository.correctionBody(
            date: DateTime(2026, 11, 3),
            type: CorrectionType.both,
            reason: '  Forgot to punch out  ',
            punchIn: '10:00',
            punchOut: '18:30'),
        {
          "attendance_date": "2026-11-03",
          "correction_type": "both",
          "reason": "Forgot to punch out",
          "requested_punch_in": "10:00",
          "requested_punch_out": "18:30",
        },
      );
      final onlyIn = AttendanceRepository.correctionBody(
          date: DateTime(2026, 11, 3),
          type: CorrectionType.punchIn,
          reason: 'Late due to traffic jam',
          punchIn: '10:00',
          punchOut: '18:30');
      expect(onlyIn["requested_punch_out"], isNull);
    });

    test('list parsing', () {
      final list = AttendanceCorrection.listFromJson({
        "total": 1,
        "items": [
          {
            "id": 7,
            "attendance_date": "2026-11-03",
            "correction_type": "both",
            "reason": "Forgot to punch out",
            "status": "pending",
            "requested_punch_in_at": "2026-11-03T10:00:00",
            "requested_punch_out_at": "2026-11-03T18:30:00",
          }
        ]
      });
      expect(list.single.isPending, isTrue);
      expect(ServerTime.istHhMm(list.single.requestedPunchOutAt!), '18:30');
    });
  });
}
