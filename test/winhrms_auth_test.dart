import 'dart:convert';

import 'package:attendance/core/apis/repository/models/attendance_status.dart';
import 'package:attendance/core/apis/repository/models/auth_response.dart';
import 'package:attendance/core/resources/constants.dart';
import 'package:attendance/core/services/auth/auth_service.dart';
import 'package:attendance/core/services/rest_api/api_base_helper.dart';
import 'package:attendance/core/services/rest_api/app_exception.dart';
import 'package:attendance/ui/screens/login/bloc/login_bloc.dart';
import 'package:attendance/ui/screens/login/helper/login_validators.dart';
import 'package:attendance/ui/screens/verifyotp/bloc/verify_otp_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WinHRMS Token + /auth/me', () {
    final Map<String, dynamic> me = {
      "id": 42,
      "employee_id": "EMP-042",
      "full_name": "Test User",
      "email": "test.user@example.com",
      "role": "manager",
      "status": "active",
      "tenant_slug": "default",
      "tenant_name": "Default Co",
      "avatar_url": null,
      "location_mandatory": true,
      "face_mandatory": true,
      "process_names": ["Ops", "QA"],
    };

    test('Token parses access_token and expiry', () {
      final auth = AuthResponse.fromJson({
        "access_token": "abc.def.ghi",
        "token_type": "bearer",
        "expires_in_minutes": 480,
      });
      expect(auth.token, "abc.def.ghi");
      expect(auth.expiresIn, 480);
    });

    test('User.fromMe maps CurrentUserResponse', () {
      final user = User.fromMe(me);
      expect(user.userId, "42");
      expect(user.name, "Test User");
      expect(user.emailId, "test.user@example.com");
      expect(user.role, "manager");
      expect(user.isActive, isTrue);
      expect(user.locationMandatory, isTrue);
      expect(user.faceMandatory, isTrue);
      expect(user.processNames, ["Ops", "QA"]);
    });

    test('persisted session round-trips token and user', () {
      final stored = authRespToJson(AuthResponse.fromJson(
              {"access_token": "tkn", "expires_in_minutes": 60})
          .copyWith(user: User.fromMe(me)));
      final restored = authRespFromJson(stored);
      expect(restored.token, "tkn");
      expect(restored.expiresIn, 60);
      expect(restored.user?.userId, "42");
      expect(restored.user?.faceMandatory, isTrue);
      expect(restored.user?.employeeId, "EMP-042");
    });

    test('roles map to RoleType', () {
      expect(AuthService.roleFromString("super_admin"), RoleType.admin);
      expect(AuthService.roleFromString("admin"), RoleType.admin);
      expect(AuthService.roleFromString("process_admin"), RoleType.admin);
      expect(AuthService.roleFromString("manager"), RoleType.manager);
      expect(AuthService.roleFromString("employee"), RoleType.employee);
      expect(AuthService.roleFromString(null), RoleType.employee);
    });
  });

  group('AttendanceStatus', () {
    test('parses today response', () {
      final s = AttendanceStatus.fromJson(json.decode('''{
        "attendance_date": "2026-11-13", "is_punched_in": true,
        "is_punched_out": false, "is_on_break": false,
        "punch_in_at": "2026-11-13T03:30:00Z", "punch_out_at": null,
        "break_started_at": null, "break_seconds": 0, "total_hours": null,
        "elapsed_seconds": 3600, "server_time": "2026-11-13T04:30:00Z"}'''));
      expect(s.isWorking, isTrue);
      expect(s.elapsedSeconds, 3600);
      expect(s.punchInAt, DateTime.utc(2026, 11, 13, 3, 30));
    });
  });

  group('error parsing', () {
    final helper = ApiBaseHelper();

    test('FastAPI string detail', () {
      expect(helper.parseErrorMsg('{"detail":"Invalid tenant or credentials"}'),
          "Invalid tenant or credentials");
    });

    test('FastAPI 422 list detail', () {
      expect(
          helper.parseErrorMsg(
              '{"detail":[{"loc":["body","email"],"msg":"bad email","type":"x"}]}'),
          "bad email");
    });

    test('legacy errors[0].detail', () {
      expect(helper.parseErrorMsg('{"errors":[{"detail":"old"}]}'), "old");
    });

    test('non-JSON falls back', () {
      expect(helper.parseErrorMsg('<html>', defaultMsg: "x"), "x");
    });

    test('UnauthorisedException still matches unAuthorization', () {
      expect(UnauthorisedException("Invalid or expired token").toString(),
          AppConstants.unAuthorization);
    });
  });

  group('login validation', () {
    test('email', () {
      expect(LoginValidation.isValidLoginEmail("a@b.co"), isTrue);
      expect(LoginValidation.isValidLoginEmail("9876543210"), isFalse);
      expect(LoginValidation.isValidLoginEmail("a@b"), isFalse);
    });
  });

  group('OTP login', () {
    test('Send OTP with an invalid email flags the field, no request', () async {
      final bloc = LoginBloc();
      final states = <LoginState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(const SendLoginOtp(email: 'not-an-email'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(states, hasLength(1));
      expect(states.single.isEmailInvalid, isTrue);
      expect(states.single.email, 'not-an-email');
      await sub.cancel();
      await bloc.close();
    });

    test('OTP sent states are distinct so resends fire listeners', () async {
      final a = LoginOtpSentState(message: 'm', expiresInSeconds: 300);
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final b = LoginOtpSentState(message: 'm', expiresInSeconds: 300);
      expect(a == b, isFalse);
    });
  });

  group('OTP code length (6 digits, per API docs)', () {
    test('signup verify code', () {
      expect(VerifyOtpBloc.isValidCode('12345'), isFalse);
      expect(VerifyOtpBloc.isValidCode('123456'), isTrue);
      expect(VerifyOtpBloc.isValidCode('1234567'), isFalse);
      expect(VerifyOtpBloc.isValidCode('12a456'), isFalse);
    });

    test('signup state is valid only with 6 digits', () {
      expect(const VerifyOtpState(code: '12345').isValid, isFalse);
      expect(const VerifyOtpState(code: '123456').isValid, isTrue);
    });
  });
}
