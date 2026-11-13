// WinHRMS live smoke test — run it yourself with a test account.
//
// Read-only by default (login, /auth/me, /attendance/today, optional
// validate-location). Parses every response with the app's own models, so a
// contract drift shows up as a FAIL.
//
//   export WINHRMS_EMAIL=you@company.com
//   export WINHRMS_PASSWORD='...'          # never commit this
//   dart run tool/winhrms_smoke.dart
//   dart run tool/winhrms_smoke.dart --lat 23.2599 --lng 77.4126
//
// Optional steps that CHANGE DATA on the server (today's attendance row):
//   --biometric-start      start an "in" face session (no punch; it expires)
//   --punch-cycle          punch-in → break start → break end → punch-out
//                          (non-face accounts only). Requires --yes-write.
//
// Env: WINHRMS_BASE_URL (default https://winhrms.wewinlimited.com),
//      WINHRMS_TENANT (default "default"). The token is never printed.

import 'dart:convert';
import 'dart:io';

import 'package:attendance/core/apis/repository/models/attendance_status.dart';
import 'package:attendance/core/apis/repository/models/auth_response.dart';
import 'package:attendance/core/apis/repository/models/biometric_session.dart';
import 'package:http/http.dart' as http;

late final String base;
String? token;
int failures = 0;

Future<void> main(List<String> args) async {
  final env = Platform.environment;
  base = env['WINHRMS_BASE_URL'] ?? 'https://winhrms.wewinlimited.com';
  final email = env['WINHRMS_EMAIL'];
  final password = env['WINHRMS_PASSWORD'];
  final tenant = env['WINHRMS_TENANT'] ?? 'default';
  if (email == null || password == null) {
    stderr.writeln('Set WINHRMS_EMAIL and WINHRMS_PASSWORD first.');
    exit(2);
  }
  final double? lat = _argDouble(args, '--lat');
  final double? lng = _argDouble(args, '--lng');
  final bool write = args.contains('--yes-write');

  stdout.writeln('WinHRMS smoke → $base (tenant "$tenant")\n');

  // 1. Login
  final login = await _call('POST', '/api/auth/login/json',
      body: {'email': email, 'password': password, 'tenant_slug': tenant});
  final auth = _check('login returns access_token', login, 200, (j) {
    final a = AuthResponse.fromJson(j);
    if (a.token.isEmpty) throw 'access_token missing';
    return a;
  });
  if (auth == null) return _done();
  token = auth.token;

  // 2. /auth/me
  final me = _check('GET /auth/me maps to User', await _call('GET', '/api/auth/me'),
      200, (j) {
    final u = User.fromMe(j);
    if (u.userId == '0' || (u.emailId ?? '').isEmpty) throw 'id/email missing';
    return u;
  });
  if (me != null) {
    stdout.writeln('     role=${me.role} status=${me.status} '
        'location_mandatory=${me.locationMandatory} '
        'face_mandatory=${me.faceMandatory}');
  }

  // 3. /attendance/today
  final today = _check('GET /attendance/today parses',
      await _call('GET', '/api/attendance/today'), 200,
      (j) => AttendanceStatus.fromJson(j));
  if (today != null) {
    stdout.writeln('     date=${today.attendanceDate} in=${today.isPunchedIn} '
        'out=${today.isPunchedOut} break=${today.isOnBreak} '
        'elapsed=${today.elapsedSeconds}s');
  }

  // 4. validate-location
  if (lat != null && lng != null) {
    _check('POST validate-location', await _call('POST',
        '/api/attendance/validate-location',
        body: {'latitude': lat, 'longitude': lng}), 200, (j) {
      stdout.writeln('     ok=${j['ok']} message="${j['message']}"');
      return j;
    });
  }

  // 5. Bad token must be rejected (app logs the user out on this).
  final saved = token;
  token = 'invalid.token.value';
  _check('bad token → 401', await _call('GET', '/api/auth/me'), 401, (j) => j);
  token = saved;

  // 6. Optional writes
  if (args.contains('--biometric-start')) {
    if (!write) {
      stdout.writeln('SKIP biometric-start (add --yes-write)');
    } else {
      _check('POST biometric-sessions (in)', await _call('POST',
          '/api/attendance/biometric-sessions', body: {'action': 'in'}), 200,
          (j) {
        final s = BiometricSession.fromJson(j);
        stdout.writeln('     challenge=${s.challenge.map((p) => p.apiValue).toList()} '
            'frames=${s.minFrames}-${s.maxFrames} expires=${s.expiresAt}');
        return s;
      });
    }
  }

  if (args.contains('--punch-cycle')) {
    if (!write) {
      stdout.writeln('SKIP punch-cycle (add --yes-write)');
    } else if (me?.faceMandatory ?? false) {
      stdout.writeln('SKIP punch-cycle: account is face_mandatory '
          '(test that on a phone)');
    } else {
      for (final step in [
        ('punch-in', '/api/attendance/punch-in',
            {if (lat != null) 'latitude': lat, if (lng != null) 'longitude': lng}),
        ('break start', '/api/attendance/break/start', null),
        ('break end', '/api/attendance/break/end', null),
        ('punch-out', '/api/attendance/punch-out', <String, dynamic>{}),
      ]) {
        final r = _check('POST ${step.$1}',
            await _call('POST', step.$2, body: step.$3), 200, (j) {
          final rec = AttendanceStatus.fromJson(j['record']);
          stdout.writeln('     "${j['message']}" in=${rec.isPunchedIn} '
              'out=${rec.isPunchedOut} break=${rec.isOnBreak}');
          return rec;
        });
        if (r == null) break;
      }
    }
  }

  _done();
}

Future<http.Response> _call(String method, String path,
    {Map<String, dynamic>? body}) async {
  final headers = <String, String>{
    'Accept': 'application/json',
    if (body != null) 'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  final uri = Uri.parse('$base$path');
  return method == 'GET'
      ? http.get(uri, headers: headers)
      : http.post(uri,
          headers: headers, body: body == null ? null : jsonEncode(body));
}

T? _check<T>(String name, http.Response r, int expected,
    T Function(Map<String, dynamic>) parse) {
  try {
    if (r.statusCode != expected) {
      throw 'HTTP ${r.statusCode}: ${_short(r.body)}';
    }
    final T v = parse(jsonDecode(r.body) as Map<String, dynamic>);
    stdout.writeln('PASS $name');
    return v;
  } catch (e) {
    failures++;
    stdout.writeln('FAIL $name — $e');
    return null;
  }
}

String _short(String s) => s.length > 200 ? '${s.substring(0, 200)}…' : s;

double? _argDouble(List<String> args, String flag) {
  final i = args.indexOf(flag);
  return i >= 0 && i + 1 < args.length ? double.tryParse(args[i + 1]) : null;
}

void _done() {
  stdout.writeln(failures == 0 ? '\nAll checks passed.' : '\n$failures check(s) failed.');
  exit(failures == 0 ? 0 : 1);
}
