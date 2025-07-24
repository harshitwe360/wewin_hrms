import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/config/config.dart';
import '../bloc/correction_cubit.dart';

class CorrectionView extends StatelessWidget{
  const CorrectionView({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 24),
      child: _correctionButtonView(context),
    );
  }
  
  Widget _correctionButtonView(BuildContext context){
    return OutlinedButton(
        onPressed: () => showResignDialog(context),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(12.0),
          foregroundColor: AppColors.colorAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Custom border radius
          ),
          // backgroundColor: Colors.white, // Background color
          side: BorderSide(color: AppColors.colorAccent), // Border color
        ),
        child: Text('Correction', style: TextStyle(fontSize: 16),),
      );
  }

  void showResignDialog(BuildContext context) {
    TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocConsumer<CorrectionCubit, CorrectionState>(
          listener: (context, state) {
            if (state == CorrectionState.success) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Correction Request submitted successfully!')),
              );
            } else if (state == CorrectionState.failure) {
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
                child: state == CorrectionState.loading
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
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Correction Request',
                        style: Theme.of(context).textTheme.largeXValue,
                      ),
                    ),
                    const VerticalLine(
                        color: Colors.black12,
                        radius: 30.0,
                        width: double.infinity,
                        height: 1),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Date : ${AppHelper.dateFormat(date: date, format: 'dd MMMM yyyy')}',
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
                                  context.read<CorrectionCubit>().submitCorrection(reason, date);
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