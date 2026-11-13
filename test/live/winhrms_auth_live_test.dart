// LIVE tests: the app's real auth/session/logout code against WinHRMS.
//
// Read-only: logs in, reads /auth/me and /attendance/today, and exercises
// local logout. It never punches and never requests an OTP email.
// Skipped unless credentials are provided:
//
//   WINHRMS_EMAIL=... WINHRMS_PASSWORD=... flutter test test/live
//
// Platform plugins (secure storage, connectivity) are replaced with
// in-memory fakes; HTTP is real.

import 'dart:async';
import 'dart:io';

import 'package:attendance/core/apis/repository/attendance_repo.dart';
import 'package:attendance/core/apis/repository/models/attendance_status.dart';
import 'package:attendance/core/apis/repository/models/monthly_attendance.dart';
import 'package:attendance/core/apis/repository/models/auth_response.dart';
import 'package:attendance/core/resources/constants.dart';
import 'package:attendance/core/services/auth/auth_service.dart';
import 'package:attendance/core/services/rest_api/api_base_helper.dart';
import 'package:attendance/core/services/rest_api/app_exception.dart';
import 'package:attendance/core/apis/api_endpoints.dart';
import 'package:attendance/ui/screens/forgot_password/bloc/password_reset_cubit.dart';
import 'package:attendance/ui/screens/login/bloc/login_bloc.dart';
import 'package:attendance/ui/screens/login/repository/auth_rest_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final Map<String, String> _store = {};

/// Session captured from one successful login, restored before each test so
/// the suite stays well under the server's login rate limit.
Map<String, String>? _session;

Future<void> _useSession(AuthRepository repo, String email, String pw) async {
  if (_session == null) {
    await repo.login(email: email, password: pw);
    _session = Map.of(_store);
  }
  _store
    ..clear()
    ..addAll(_session!);
}

void _fakePlugins() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
    final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
    final key = args['key'] as String?;
    switch (call.method) {
      case 'write':
        _store[key!] = args['value'] as String;
        return null;
      case 'read':
        return _store[key];
      case 'delete':
        _store.remove(key);
        return null;
      case 'containsKey':
        return _store.containsKey(key);
      case 'readAll':
        return Map<String, String>.from(_store);
      case 'deleteAll':
        _store.clear();
        return null;
    }
    return null;
  });
  messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (_) async => <String>['wifi']);
  messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
      (_) async => null);
}

/// Dispatches [event] and collects states until [done] matches.
Future<List<LoginState>> _run(LoginBloc bloc, LoginEvent event,
    bool Function(LoginState) done) async {
  final states = <LoginState>[];
  final completer = Completer<void>();
  final sub = bloc.stream.listen((s) {
    states.add(s);
    if (done(s) && !completer.isCompleted) completer.complete();
  });
  bloc.add(event);
  await completer.future.timeout(const Duration(seconds: 45));
  await Future<void>.delayed(const Duration(milliseconds: 50));
  await sub.cancel();
  return states;
}

bool _terminal(LoginState s) =>
    s is LoginFinishedState || s is LoginErrorState;

void main() {
  final email = Platform.environment['WINHRMS_EMAIL'];
  final password = Platform.environment['WINHRMS_PASSWORD'];
  final skip = (email == null || password == null)
      ? 'Set WINHRMS_EMAIL and WINHRMS_PASSWORD to run live tests'
      : null;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null; // allow real network
    _fakePlugins();
  });
  setUp(_store.clear);

  final repo = AuthRepository();

  group('Login (POST /api/auth/login/json)', () {
    test('LoginBloc: invalid email is rejected before any request', () async {
      final bloc = LoginBloc();
      bloc.add(const EmailChanged(email: 'abhishek'));
      bloc.add(const PasswordChanged(password: 'x'));
      final states = await _run(bloc, const Submitted(),
          (s) => s.runtimeType == LoginState && s.isEmailInvalid);
      expect(states.last.isEmailInvalid, isTrue);
      expect(_store, isEmpty);
      await bloc.close();
    });

    test('LoginBloc: valid credentials → signed in, token + user stored',
        () async {
      final bloc = LoginBloc();
      bloc.add(EmailChanged(email: email!));
      bloc.add(PasswordChanged(password: password!));
      final states = await _run(bloc, const Submitted(), _terminal);
      final last = states.whereType<LoginFinishedState>().toList();
      expect(states.whereType<LoginErrorState>(), isEmpty,
          reason: states.whereType<LoginErrorState>().map((e) => e.message).join());
      expect(last.single.isSuccess, isTrue);

      final token = _store[AppConstants.token];
      expect(token, isNotNull);
      expect(token!.split('.'), hasLength(3), reason: 'JWT');

      final AuthResponse auth = await AuthService.instance.getCurrentUserData();
      expect(auth.token, token);
      expect(auth.user, isNotNull);
      expect(auth.user!.emailId?.toLowerCase(), email.toLowerCase());
      expect(auth.user!.userId, isNot('0'));
      expect(auth.user!.isActive, isTrue);
      expect(auth.user!.tenantSlug, AppConstants.defaultTenantSlug);
      // ignore: avoid_print
      print('  user id=${auth.user!.userId} role=${auth.user!.role} '
          'location_mandatory=${auth.user!.locationMandatory} '
          'face_mandatory=${auth.user!.faceMandatory} '
          'expires_in_minutes=${auth.expiresIn}');
      await bloc.close();
    });
    test('wrong password → server message, nothing stored', () async {
      await expectLater(
          repo.login(email: email!, password: '${password!}-wrong'),
          throwsA(predicate((e) => '$e' == 'Invalid tenant or credentials')));
      expect(_store[AppConstants.token], isNull);
      expect(_store[AppConstants.loginDetails], isNull);
    });

  }, skip: skip);

  group('Session / token handling', () {
    setUp(() => _useSession(repo, email!, password!));

    test('stored token authorises /auth/me and /attendance/today', () async {
      final user = await repo.fetchMe();
      expect(user.emailId?.toLowerCase(), email!.toLowerCase());
      final AttendanceStatus today = await AttendanceRepository().getToday();
      expect(today.attendanceDate, isNotEmpty);
      // ignore: avoid_print
      print('  today=${today.attendanceDate} in=${today.isPunchedIn} '
          'out=${today.isPunchedOut} break=${today.isOnBreak}');
    });

    test('app start (RefreshToken) with a valid token → dashboard', () async {
      final bloc = LoginBloc();
      final states = await _run(bloc, const RefreshToken(), _terminal);
      expect((states.last as LoginFinishedState).isSuccess, isTrue);
      expect(_store[AppConstants.token], isNotNull);
      await bloc.close();
    });

    test('login/OTP requests do not send a stale bearer', () async {
      // A stale token must not break a fresh login.
      _store[AppConstants.token] = 'invalid.token.value';
      expect(await repo.login(email: email!, password: password!), isTrue);
      expect(_store[AppConstants.token], isNot('invalid.token.value'));
      // WinHRMS keeps one session per user: this login invalidated the
      // shared one, so later tests must use this newer session.
      _session = Map.of(_store);
    });
  }, skip: skip);

  group('Logout (local; WinHRMS has no logout route)', () {
    setUp(() => _useSession(repo, email!, password!));

    test('Logout follows today\'s punch state', () async {
      final today = await AttendanceRepository().getToday();
      final bloc = LoginBloc();
      final states = await _run(bloc, const Logout(), _terminal);
      if (today.isWorking) {
        expect(states.last, isA<LoginErrorState>());
        expect((states.last as LoginErrorState).message,
            contains('before punch-out'));
        expect(_store[AppConstants.token], isNotNull,
            reason: 'session kept while punched in');
      } else {
        expect((states.last as LoginFinishedState).isSuccess, isTrue);
        expect(_store[AppConstants.token], isNull);
        expect(_store[AppConstants.loginDetails], isNull);
        // The old token is only forgotten locally; nothing to revoke.
      }
      // ignore: avoid_print
      print('  punched in now: ${today.isWorking} → '
          '${states.last.runtimeType}');
      await bloc.close();
    });

  }, skip: skip);

  // No valid login needed: these only send a forged token.
  group('Single session per user', () {
    test('a newer login invalidates the previous token', () async {
      await _useSession(repo, email!, password!);
      final String oldToken = _store[AppConstants.token]!;
      expect(await repo.login(email: email, password: password), isTrue);
      _session = Map.of(_store);
      expect(_store[AppConstants.token], isNot(oldToken));

      // The previous token is now rejected → the app signs that device out.
      _store[AppConstants.token] = oldToken;
      final bloc = LoginBloc();
      final states = await _run(bloc, const RefreshToken(), _terminal);
      expect((states.last as LoginFinishedState).isSuccess, isFalse);
      expect(_store[AppConstants.token], isNull);
      await bloc.close();
    });
  }, skip: skip);

  group('Attendance history (read-only)', () {
    setUp(() => _useSession(repo, email!, password!));

    test('monthly-attendance parses every day of the month', () async {
      final now = DateTime.now();
      final MonthlyAttendance m = await AttendanceRepository()
          .getMonthlyAttendance(month: now.month, year: now.year);
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      expect(m.days, hasLength(daysInMonth));
      expect(m.days.where((d) => d.hasPunch).length, m.presentDays);
      // ignore: avoid_print
      print('  ${m.userName}: present=${m.presentDays} '
          'hours=${m.totalHoursWorked} '
          'weekOff=${m.days.where((d) => d.isWeekOff).length}');
    });

    test('holidays and my corrections parse', () async {
      final repo2 = AttendanceRepository();
      final holidays = await repo2.getHolidays(DateTime.now().year);
      final corrections = await repo2.getMyCorrections();
      // ignore: avoid_print
      print('  holidays=${holidays.length} corrections=${corrections.length}');
      expect(holidays.every((h) => h.name.isNotEmpty), isTrue);
    });
  }, skip: skip);

  // No login needed and no email is sent: only a fake reset link.
  group('Password reset (no login)', () {
    test('an invalid reset link shows the server message', () async {
      final cubit = PasswordResetCubit();
      await cubit.reset(
          tokenOrLink: 'https://winhrms.wewinlimited.com/login'
              '?reset_token=this-is-not-a-real-reset-token-000',
          password: 'abcdefgh');
      expect(cubit.state.status, ResetStatus.failure);
      expect(cubit.state.message, 'Invalid or expired reset link');
      await cubit.close();
    });
  });

  group('Rejected token (no login)', () {
    test('app start with an invalidated token → login, session cleared',
        () async {
      _store[AppConstants.token] = 'invalid.token.value';
      final bloc = LoginBloc();
      final states = await _run(bloc, const RefreshToken(), _terminal);
      expect((states.last as LoginFinishedState).isSuccess, isFalse);
      expect(_store[AppConstants.token], isNull);
      expect(_store[AppConstants.loginDetails], isNull);
      await bloc.close();
    });

    test('any WinHRMS 401 clears the stored session', () async {
      _store[AppConstants.token] = 'invalid.token.value';
      await expectLater(
          ApiBaseHelper().request(
              baseUrlType: ApiEndpoints.baseUrl,
              url: ApiEndpoints.attendanceToday,
              method: MethodType.get,
              checkAuth: true),
          throwsA(isA<UnauthorisedException>()));
      expect(_store[AppConstants.token], isNull);
    });

    test('Logout with an already-rejected token still signs out', () async {
      _store[AppConstants.token] = 'invalid.token.value';
      final bloc = LoginBloc();
      final states = await _run(bloc, const Logout(), _terminal);
      expect((states.last as LoginFinishedState).isSuccess, isTrue);
      expect(_store[AppConstants.token], isNull);
      await bloc.close();
    });
  });
}
