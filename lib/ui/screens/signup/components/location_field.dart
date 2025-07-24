import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/drop_down_view.dart';
import '../bloc/signup_bloc.dart';

class LocationDropDown extends StatelessWidget {
  const LocationDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) {
        return previous.isLocationInvalid != current.isLocationInvalid
            || previous.locationList != current.locationList;
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 22.0),
          child: DropDownView(
            labelText: 'Location *',
            isShowId: false,
            value: state.location,
            onChanged: (newValue) {
              if (newValue != null) {
                context.read<SignupBloc>().add(LocationChanged(location: newValue));
              }
            },
            items: state.locationList,
            errorText: state.isLocationInvalid
                ? "Invalid Location."
                : null,
          ),
        );
      },
    );
  }
}