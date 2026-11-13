import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import 'login_styles.dart';

/// "Sign in →" for the Work email (password) tab.
class SubmitLogin extends StatelessWidget {
  const SubmitLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginGradientButton(
      label: "Sign in",
      onPressed: () => context.read<LoginBloc>().add(const Submitted()),
    );
  }
}
