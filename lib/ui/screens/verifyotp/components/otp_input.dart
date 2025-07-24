import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/config.dart';
import '../bloc/verify_otp_bloc.dart';

class OtpInput extends StatefulWidget {
  final int length;

  const OtpInput({super.key, this.length = 4});

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _controllers = List.generate(widget.length, (_) => TextEditingController());

    // Listen to BLoC state to update controllers if needed
    final bloc = context.read<VerifyOtpBloc>();
    bloc.stream.listen((state) {
      for (int i = 0; i < widget.length; i++) {
        if (_controllers[i].text != state.digits[i]) {
          _controllers[i].text = state.digits[i];
        }
      }
    });
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      value = value.substring(value.length - 1);
      _controllers[index].text = value;
    }

    if (value.isNotEmpty) {
      context.read<VerifyOtpBloc>().add(OtpDigitChanged(index: index, digit: value));
      if (index + 1 < widget.length) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    } else {
      context.read<VerifyOtpBloc>().add(OtpDigitChanged(index: index, digit: value));
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerifyOtpBloc, VerifyOtpState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.length, (index) {
            return SizedBox(
              width: 50,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                // style: TextStyle(fontSize: R.dimens.fontSizeMedium, color: AppColors.textDark),
                decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _onChanged(value, index),
              ),
            );
          }),
        );
      },
    );
  }
}
