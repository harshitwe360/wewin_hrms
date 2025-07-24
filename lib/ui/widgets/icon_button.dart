import 'package:flutter/material.dart';
import '../../core/config/config.dart';

class IconsButton extends StatelessWidget {
  final Function onPressed;
  final IconData? icon;
  const IconsButton({Key? key, required this.onPressed, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.colorPrimary,
          minimumSize: const Size(100, 26),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        onPressed: () => onPressed(),
        child: Icon(icon ?? Icons.arrow_forward),
      ),
    );
    /*return BlocListener(
        bloc: context.read<LoginBloc>(),
        listener: (context, state) {
          *//*if (state is LoginFinishedState) {
            if (state.isSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.components, (r) => false);
            } else {
              // show error message
            }
          } else if (state is LoginErrorState) {
            // API error message show here
          }*//*
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              onPrimary: AppColors.white,
              primary: AppColors.colorPrimary,
              minimumSize: const Size(160, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onPressed: () => context.read<LoginBloc>().add(const Submitted()),
                // .add(const Submitted(clientId: AppConstants.CLIENT_ID)),
            child: Text(R.strings.btnLogin),
          ),
        ));*/
  }
}
