import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../../../core/config/config.dart';
import '../bloc/calendar_cubit.dart';

class MemberNameView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  final Color? bgColor;

  const MemberNameView(
      {super.key, this.animationController, this.animation, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      child: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          if (state is CalendarLoadedState) {
            {
              return Container(
                decoration: BoxDecorationX.panel,
                width: double.infinity,
                margin: PaddingC.boxPadding,
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: bgColor,
                      radius: 18,
                      child: state.attendance.userName.trim().isNotEmpty
                          ? Text(
                        AppHelper.getAvatarString(state.attendance.userName),
                        style: Theme.of(context).textTheme.largeXLabel
                            .copyWith(color: AppColors.white),
                      )
                          : const Icon(Icons.person), //Text
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 10.0),
                        child: Text(state.attendance.userName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            // textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.largeLabel
                                .copyWith(color: AppColors.darkText)),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
          return Container();
        },
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
