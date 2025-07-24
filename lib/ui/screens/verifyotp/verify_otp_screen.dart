import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/apis/repository/models/auth_response.dart';
import '../../../core/config/config.dart';
import '../login/components/bottom_ui.dart';
import '../login/components/login_bg_box.dart';
import 'bloc/verify_otp_bloc.dart';
import 'components/otp_input.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({super.key, this.arguments});
  final Map<String, dynamic>? arguments;

  void _submitOtp(BuildContext context, String emailId) {
    context.read<VerifyOtpBloc>().add(OtpSubmitted(emailId: emailId));
  }

  void _resendOtp(BuildContext context, String emailId) {
    context.read<VerifyOtpBloc>().add(OtpResendRequested(emailId: emailId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP has been resent.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? emailId = arguments?['mobileNo'];
    // final String? emailId = '7828590595';
    // final bool isSignUp = arguments?['isSignUp'] ?? false;

    return BlocProvider(
      create: (context) => VerifyOtpBloc()..add(
          OtpResendRequested(emailId: emailId ?? '')),
      child: Scaffold(
          body: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  child: SvgPicture.asset(
                      R.icon.loginDesign01, height: 166,
                      semanticsLabel: R.strings.btnFilter
                  )),
              _pageContainer(context, emailId),
            ],
          ),
        ),
    );
  }

  Widget _pageContainer(BuildContext context, String? emailId) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 3.4,
            child: Padding(
              padding: EdgeInsets.only(top: 35),
              child: Container(
                width: 120.0,
                alignment: Alignment.center,
                child: Image.asset(
                  R.images.logo,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          BlocListener<VerifyOtpBloc, VerifyOtpState>(
            listener: (context, state) {
              if (state.isSubmitting) {
                LoadingDialog.show(context);
              } else if (state.isSuccess) {
                LoadingDialog.hide(context); // Dismiss the loading
                AppHelper.showSnackBar(context,
                    snackBarMode: SnackBarMode.success,
                    content: 'Congratulations! Your account has been created.\n Your ID and password will be delivered shortly.');
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (r) => false);
              } else if (state.isFailure) {
                LoadingDialog.hide(context); // Dismiss the loading
                AppHelper.showSnackBar(context,
                    snackBarMode: SnackBarMode.error,
                    content: 'Invalid OTP. Please try again.!');
              }
            },
            child: _formView(context, emailId),
          ),
          const BottomLogin(),
        ]);
  }

  Widget _formView(BuildContext context, String? emailId){
    return Expanded(
      child: CustomPaint(
        painter: LoginBgShape(color:AppColors.colorPrimary),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 40.0, right: 40.0, top: 33.0, bottom: 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _profileHeader(context, emailId),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 52.0),
                  child: const OtpInput(length: 4),
                ),
                RichText(
                  text: TextSpan(
                    text: "Didn't receive ? ",
                    style: Theme.of(context).textTheme.smallLabel,
                    children: [
                      /*WidgetSpan(
                          child: InkWell(
                            onTap: () => _resendOtp(context, user?.emailId ?? ''),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(2.0, 6.0, 6.0, 0),  // Padding around the text
                              child: Text(' Resend OTP',
                                  style: Theme.of(context).textTheme.smallValue.copyWith(
                                      color: AppColors.colorAccent)
                              ),
                            ),
                          ),
                        ),*/
                      WidgetSpan(
                          child: getTimerView(emailId ?? '')
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<VerifyOtpBloc, VerifyOtpState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.isValid && !state.isSubmitting
                          ? () => _submitOtp(context, emailId ?? '')
                          : null,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                          backgroundColor: AppColors.colorAccent2,
                          disabledBackgroundColor: AppColors.colorAccent2
                              .withOpacity(0.6)
                      ),
                      child: Text('Verify OTP',
                          style: Theme.of(context).textTheme.mediumLabel
                              .copyWith(color: AppColors.white)),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getTimerView(String emailId){
    return StreamBuilder<int>(
      stream: timerStream(60),  // Start a 60-second countdown
      builder: (context, snapshot) {
        if(snapshot.data == 0){
          return InkWell(
            onTap: () => _resendOtp(context, emailId),
            child: Container(
              padding: const EdgeInsets.fromLTRB(2.0, 6.0, 6.0, 0),  // Padding around the text
              child: Text(' Resend OTP',
                  style: Theme.of(context).textTheme.smallValue.copyWith(
                      color: AppColors.colorAccent)
              ),
            ),
          );
        }
        return IntrinsicWidth(
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 12, color: Colors.green),
              const SizedBox(width: 2),
              Text(
                'OTP Resent ',
                style: Theme.of(context).textTheme.smallValue
                    .copyWith(color: Colors.green),
              ),
              Text(
                snapshot.hasData ? getTime(snapshot.data ?? 0) : '00:00',
                style: Theme.of(context).textTheme.smallValue,
              ),
            ],
          ),
        );
      },
    );
  }

  String getTime(int seconds){
    final String min = (Duration(seconds: seconds).inMinutes % 60).toString();
    final String sec = (Duration(seconds: seconds).inSeconds % 60).toString();
    return '${min.padLeft(2, '0')}:${sec.padLeft(2, '0')}';
  }

  // Stream that emits a value every second
  Stream<int> timerStream(int seconds) {
    return Stream.periodic(const Duration(seconds: 1),
            (count) => seconds - count - 1)
        .takeWhile((value) => value >= 0);  // Stop the stream when timer hits 0
  }

  Widget _profileHeader(BuildContext context, String? emailId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
          children: [
            Text("Verify Account",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.largeXIXValue
                    .copyWith(fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: AppColors.black)),
            // const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                textAlign: TextAlign.center,
                textScaleFactor: 1.1,
                text: TextSpan(
                  text: "We’ve sent an SMS with an activation code to \n",
                  style: Theme.of(context).textTheme.mediumLabel,
                  children: <TextSpan>[
                    TextSpan(text: ' your phone '),
                    TextSpan(
                        text: "+91 ${emailId ?? ''}",
                        style: Theme.of(context).textTheme.mediumValue.copyWith(
                            // decoration: TextDecoration.underline,
                            color: AppColors.colorAccent)
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            /*Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text("An OTP has been sent to Mobile Number ${emailId!=null ? '\n $emailId' :''}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.smallLabel
              ),
            ),*/
          ]
      ),
    );
  }

}