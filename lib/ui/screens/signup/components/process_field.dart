import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/drop_down_view.dart';
import '../bloc/signup_bloc.dart';

class ProcessDropDown extends StatelessWidget {
  const ProcessDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) {
        return previous.process != current.process
            || previous.processList != current.processList;
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 22.0),
          child: DropDownView(
            labelText: 'Process *',
            isShowId: false,
            value: state.process,
            onChanged: (newValue) {
              if (newValue != null) {
                context.read<SignupBloc>().add(ProcessChanged(process: newValue));
              }
            },
            items: state.processList ?? [],
            errorText: state.isProcessInvalid
                ? "Invalid Process."
                : null,
          ),
        );
      },
    );
  }
}