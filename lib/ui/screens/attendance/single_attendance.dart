import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'detail/bloc/calendar_cubit.dart';
import 'detail/my_attendance.dart';

class SingleAttendance extends StatefulWidget {
  const SingleAttendance({super.key, required this.userId, this.bgColor});

  final String userId;
  final Color? bgColor;

  @override
  State<SingleAttendance> createState() => _SingleAttendanceState();
}

class _SingleAttendanceState extends State<SingleAttendance>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  final String name = "";

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<CalendarCubit>(
            create: (context) => CalendarCubit(),
          ),
        ],
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: MyAttendance(
                      isInnerScreen: false,
                      bgColor: widget.bgColor,
                      animationController: animationController,
                      userId: widget.userId)),
            ],
          ),
        ),
    );
  }
}