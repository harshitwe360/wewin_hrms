import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/config/config.dart';
import '../bloc/calendar_cubit.dart';

class PunchHoursView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const PunchHoursView({super.key, this.animationController, this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      child: Padding(
        padding: PaddingC.boxPadding,
        child: Container(
            decoration: BoxDecorationX.panel,
            child: BlocBuilder<CalendarCubit, CalendarState>(
              builder: (context, state) {
                // double workingTime = 0, goal = 0;
                // String avgHrs = "0";
                if (state is CalendarLoadedState) {
                  {
                    // goal = state.userAttendance.goal;
                    /*double avg = ( workingTime/
                        state.userAttendance.presentDay.length);*/
                    // avgHrs = avg.isNaN ? "0":avg.toString();
                  }
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: Text(
                          "Harshit, Verify Your Attendance",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .largeLabel
                              .copyWith(color: AppColors.black),
                        )),
                    // Padding(
                    //     padding: const EdgeInsets.only(
                    //         top: 12.0, bottom: 6.0),
                    //     child: Text(
                    //       "$payableDays day${payableDays>0? '(s)': ''}",
                    //       textAlign: TextAlign.center,
                    //       style: Theme.of(context)
                    //           .textTheme
                    //           .largeXXXValue
                    //           .copyWith(color: AppColors.punchIn),
                    //     )),
                    SizedBox(height: 18),
                    Padding(
                        padding: EdgeInsets.only(bottom: 18.0),
                        child: Row(
                          children: [
                            Expanded(child: Padding(
                              padding: const EdgeInsets.only(left: 24,
                                  right: 12, top: 0, bottom: 16),
                              child: OutlinedButton(
                                onPressed: () {
                                  // Handle button press
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.colorAccent2,
                                  backgroundColor: Colors.white, // Background color
                                  side: BorderSide(color: AppColors.colorAccent2), // Border color
                                ),
                                child: Text('Disagree'),
                              ),
                            )),
                            Expanded(
                              child: ButtonFull(
                                onTap: () {},
                                label: "Agree",
                                height: 42,
                                radius: 30,
                                backgroundColor: AppColors.colorAccent,
                                padding: const EdgeInsets.only(left: 12,
                                    right: 24, top: 16, bottom: 16),
                                isShadow: false,
                              ),
                            )
                          ],
                        ),
                    ),
                    // Padding(
                    //     padding: const EdgeInsets.only(bottom: 18.0),
                    //     child: Text(
                    //       "${R.strings.txtGoal}: $goal h",
                    //       textAlign: TextAlign.center,
                    //       style:
                    //       Theme.of(context).textTheme.smallLabel,
                    //     ))
                  ],
                );
              },
            )),
      ),
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: child,
          ),
        );
      },
    );
  }
}
