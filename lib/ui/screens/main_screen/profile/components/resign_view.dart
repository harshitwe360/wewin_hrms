import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/config/config.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/resign_cubit.dart';

class ResignView extends StatelessWidget{
  const ResignView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoadedState && state.userDetails.resign!=null
            && state.userDetails.resign.isNotEmpty) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.all(12.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(
                color: Colors.red, // Red border color
                width: 1.0, // Border width
              ),
              borderRadius: BorderRadius.circular(10.0), // Optional: rounded corners
            ),
            child: Text("${state.userDetails.resign}".trim(),
              //'Resign From - 20 Jan \nResign to - 20 Feb\nResign Resign - I want to Quit from my job.',
              style: Theme.of(context).textTheme.largeValue.copyWith(color: AppColors.colorAccent2),
            ),
          );
        }
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.0),
          child: _resignButtonView(context),
        );
      },
    );
  }
  
  Widget _resignButtonView(BuildContext context){
    return OutlinedButton(
        onPressed: () => showResignDialog(context),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(12.0),
          foregroundColor: AppColors.colorAccent2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Custom border radius
          ),
          // backgroundColor: Colors.white, // Background color
          side: BorderSide(color: AppColors.colorAccent2), // Border color
        ),
        child: Text('Resign From Job', style: TextStyle(fontSize: 16),),
      );
  }

  void showResignDialog(BuildContext context) {
    TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocConsumer<ResignCubit, ResignState>(
          listener: (context, state) {
            if (state == ResignState.success) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Resign submitted successfully!')),
              );
            } else if (state == ResignState.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to submit reason.')),
              );
            }
          },
          builder: (context, state) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                child: state == ResignState.loading
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Submitting...',
                      style: Theme.of(context).textTheme.largeValue),
                    SizedBox(
                        width: double.infinity,
                        height: 150,
                        child: LoaderView(),
                    ),
                  ],
                ) : Column(
                  mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Resign Date : ${AppHelper.dateFormat(format: 'dd MMMM yyyy')}',
                        style: Theme.of(context).textTheme.largeValue,
                      ),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter Reason',
                        style: Theme.of(context).textTheme.largeValue,
                      ),
                    ),
                    SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: reasonController,
                        maxLines: 6,
                        textInputAction: TextInputAction.send,
                        style: TextStyle(fontSize: R.dimens.fontSizeLarge,
                            color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: 'Type your reason here...',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if(value.length>2) {
                            _formKey.currentState!.validate();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a reason';
                          }
                          if (value.length<25  || value.length>250) {
                            return 'Ensure the reason is over 24 characters in length.';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Text("Note: By click on submit button you are confirm to resign from job and delete you account."),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Padding(
                          padding: const EdgeInsets.only(left: 0,
                              right: 12, top: 16, bottom: 16),
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.colorAccent2,
                              backgroundColor: Colors.white, // Background color
                              side: BorderSide(color: AppColors.colorAccent2), // Border color
                            ),
                            child: Text('Cancel'),
                          ),
                        )),
                        Expanded(
                          child: ButtonFull(
                            onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  String reason = reasonController.text;
                                  context.read<ResignCubit>().submitResign(reason);
                                }
                            },
                            label: "Submit",
                            height: 42,
                            radius: 30,
                            backgroundColor: AppColors.colorAccent,
                            padding: const EdgeInsets.only(left: 12,
                                right: 0, top: 16, bottom: 16),
                            isShadow: false,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}