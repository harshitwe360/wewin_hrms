import 'package:flutter/material.dart';
import 'slide_route_builder.dart';
import '../../ui/screens/xtnd_screens.dart';
import '../../ui/widgets/unknown_routes_view.dart';

class AppRoutes {
  static const launch = '/';
  static const login = 'sign-in';
  static const signup = 'sign-up';
  static const profile = 'profile';
  static const dashboard = 'dashboard';
  static const verifyOTP = 'verify-otp';
  static const forgotPassword = 'forgot-password';
  static const resetPassword = 'reset-password';
  // static const punchLogs = 'punchLogs';
  // static const attendance = 'attendance';
  // static const attendanceDetail = 'attendance-details';
  static const singleAttendance = 'single-attendance';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case launch:
        return SlideRouteBuilder(page: const SplashScreen(), route: launch);
      case login:
        return SlideRouteBuilder(page: const LoginScreen(), route: login);
      case signup:
        return SlideRouteBuilder(page: const SignupScreen(), route: AppRoutes.signup);
      case verifyOTP:
        return SlideRouteBuilder(page: VerifyOtpScreen(
            arguments: (settings.arguments ?? {"isSignUp":false}) as Map<String, dynamic>),
            route: verifyOTP);
      case forgotPassword:
        // arguments: the email typed on the login screen (optional).
        return SlideRouteBuilder(
            page: ForgotPasswordScreen(email: (settings.arguments ?? "") as String),
            route: forgotPassword);
      case resetPassword:
        // arguments: a reset link or token to pre-fill (optional).
        return SlideRouteBuilder(
            page: ResetPasswordScreen(tokenOrLink: (settings.arguments ?? "") as String),
            route: resetPassword);
      case profile:
        return SlideRouteBuilder(page: const Profile(), route: AppRoutes.profile);
      case dashboard:
        return SlideRouteBuilder(page: const DashboardScreen());
      // case attendance:
      //   return SlideRouteBuilder(page: const AttendanceScreen());
      // case attendanceDetail:
      //   return SlideRouteBuilder(page: const AttendanceDetailScreen());
      // case punchLogs:
      //   return SlideRouteBuilder(page: const PunchLogScreen());
      case singleAttendance:
        final String userId = (settings.arguments ?? "") as String;
        return SlideRouteBuilder(
            page: SingleAttendance(userId: userId), route: AppRoutes.singleAttendance);
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const UnknownView());
  }
}
