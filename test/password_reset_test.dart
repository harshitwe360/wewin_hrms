import 'package:attendance/ui/screens/forgot_password/bloc/password_reset_cubit.dart';
import 'package:attendance/ui/screens/login/repository/auth_rest_repo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const token = 'Xy7_abcdefghijklmnopqrstuvwxyz0123';

  group('extractResetToken', () {
    test('full emailed link', () {
      expect(
          AuthRepository.extractResetToken(
              'https://winhrms.wewinlimited.com/login?reset_token=$token'),
          token);
    });
    test('link with extra params and whitespace', () {
      expect(
          AuthRepository.extractResetToken(
              '  https://winhrms.wewinlimited.com/login?a=1&reset_token=$token&b=2 \n'),
          token);
    });
    test('bare token', () {
      expect(AuthRepository.extractResetToken(' $token '), token);
    });
  });

  group('validation', () {
    test('email', () {
      expect(PasswordResetCubit.emailError('a@b.co'), isNull);
      expect(PasswordResetCubit.emailError('abhishek'), isNotNull);
    });
    test('token / link', () {
      expect(PasswordResetCubit.tokenError(''), isNotNull);
      expect(PasswordResetCubit.tokenError('short'), isNotNull);
      expect(PasswordResetCubit.tokenError(token), isNull);
      expect(
          PasswordResetCubit.tokenError(
              'https://winhrms.wewinlimited.com/login?reset_token=$token'),
          isNull);
      expect(
          PasswordResetCubit.tokenError(
              'https://winhrms.wewinlimited.com/login?reset_token=abc'),
          isNotNull,
          reason: 'truncated link');
    });
    test('password 8–128', () {
      expect(PasswordResetCubit.passwordError('1234567'), isNotNull);
      expect(PasswordResetCubit.passwordError('12345678'), isNull);
      expect(PasswordResetCubit.passwordError('x' * 129), isNotNull);
    });
  });

  test('invalid input fails without calling the server', () async {
    final cubit = PasswordResetCubit();
    await cubit.reset(tokenOrLink: 'short', password: 'abcdefgh');
    expect(cubit.state.status, ResetStatus.failure);
    await cubit.sendLink('not-an-email');
    expect(cubit.state.status, ResetStatus.failure);
    await cubit.close();
  });
}
