import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/config.dart';
import '../bloc/signup_bloc.dart';

class SubmitLogin extends StatelessWidget {
  const SubmitLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          backgroundColor: AppColors.colorAccent2
        ),
        onPressed: () => context.read<SignupBloc>().add(const Submitted()),
        child: Text("Create Account",
            style: Theme.of(context).textTheme.largeValue
                .copyWith(color: AppColors.white)),
      ),
    );
  }
}
