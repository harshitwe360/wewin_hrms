import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../../core/apis/repository/models/punch_logs.dart';
import '../../../../../../core/config/config.dart';
import '../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../core/apis/repository/models/filter_model.dart';
import '../bloc/calendar_cubit.dart';
import '../bloc/calendar_log_cubit.dart';
import 'calendar_events_item_view.dart';
import 'correction_view.dart';

class Event {
  final String title;
  final Color color;

  const Event({required this.title, required this.color});
}

class CalendarView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String? userId;

  const CalendarView(
      {super.key, this.animationController, this.animation, this.userId});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  int absentDays = 0, presentDays = 0, weekEndDays = 0;

  late FilterModel _filter;

  late LinkedHashMap<DateTime, List<Event>> kEvents;
  Map<DateTime, List<Event>> _kEventSource = {};

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  @override
  void initState() {
    _filter = FilterModel(
        startDate: AppHelper.dateFormat(endDays: 6),
        endDate: AppHelper.dateFormat(),
        userId: widget.userId);
    kEvents = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_kEventSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      child: Padding(
        padding: PaddingC.boxPadding,
        child: Container(
          padding: const EdgeInsets.only(bottom: 25.0, top: 12),
          decoration: BoxDecorationX.panel,
          child: BlocConsumer<CalendarCubit, CalendarState>(
            listener: (context, state) {
              if (state is CalendarLoadingState) {
                LoadingDialog.show(context);
              } else {
                LoadingDialog.hide(context);
              }
              if (state is CalendarErrorState) {
                AppHelper.showSnackBar(context,
                    snackBarMode: SnackBarMode.error, content: state.message);
                if(state.message == AppConstants.unAuthorization){
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
                }
              }
            },
            builder: (context, state) {
              if (state is CalendarLoadedState) {
                if (state.userAttendance != null) {
                  presentDays = state.userAttendance.present;
                  absentDays = state.userAttendance.absent;
                  weekEndDays = state.userAttendance.weekend;
                  _kEventSource = {
                    for (var item in state.userAttendance.presentDay)
                      item: [
                        Event(
                            title: R.strings.txtPresent, color: AppColors.punchIn)
                      ],
                    for (var item in state.userAttendance.absentDay)
                      item: [
                        Event(title: R.strings.txtAbsent, color: AppColors.absent)
                      ],
                    for (var item in state.userAttendance.weekendDay)
                      item: [
                        Event(title: "Weekend", color: AppColors.punchOut)
                      ]
                  };
                  kEvents = LinkedHashMap<DateTime, List<Event>>(
                    equals: isSameDay,
                    hashCode: getHashCode,
                  )..addAll(_kEventSource);
                }
              }
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    tableCalendar(),
                    const Divider(color: AppColors.black26),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 16, top: 8, bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: VerticalLabelValueUp(
                                bgColor: AppColors.punchIn,
                                isCircle: true,
                                label: R.strings.txtPresent,
                                value:
                                    '${AppHelper.formatInt2(string: presentDays.toString())} ${R.strings.txtDays}'),
                          ),
                          Expanded(
                            child: VerticalLabelValueUp(
                                bgColor: AppColors.absent,
                                isCircle: true,
                                leftPadding: 0,
                                label: R.strings.txtAbsent,
                                value:
                                    '${AppHelper.formatInt2(string: absentDays.toString())} ${R.strings.txtDays}'),
                          ),
                          Expanded(
                            child: VerticalLabelValueUp(
                                bgColor: AppColors.punchOut,
                                isCircle: true,
                                leftPadding: 0,
                                label: "Week OFF",
                                value:
                                    '${AppHelper.formatInt2(string: weekEndDays.toString())} ${R.strings.txtDays}'),
                          )
                        ],
                      ),
                    ),
                  ]);
            },
          ),
        ),
      ),
      builder: (BuildContext aContext, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: child,
          ),
        );
      },
    );
  }

  Widget tableCalendar() {
    return TableCalendar<Event>(
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        _filter = _filter.copyWith(
            startDate: AppHelper.firstDayOfMonth(date: focusedDay),
            endDate: AppHelper.lastDayOfMonth(date: focusedDay));
        context.read<CalendarCubit>().getCalendarInitData(_filter);
      },
      availableGestures: AvailableGestures.horizontalSwipe,
      eventLoader: _getEventsForDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          _filter = _filter.copyWith(
              startDate: AppHelper.dateFormat(date: selectedDay),
              endDate: AppHelper.dateFormat(date: selectedDay));
          context.read<CalendarLogCubit>().getCalendarLogData(_filter);
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
        _showBottomSheet(context);
      },
      // shouldFillViewport: true,
      weekNumbersVisible: false,
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.now(),
      currentDay: DateTime.now(),
      focusedDay: _focusedDay, //DateTime.now(),
      calendarBuilders: CalendarBuilders(
        singleMarkerBuilder: (context, date, event) {
          return Container(
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                color: date == _selectedDay
                    ? AppColors.absent
                    : event.color), //Change color
            width: 10.0,
            height: 3.0,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
          );
        },
      ),
      headerStyle: HeaderStyle(
          titleTextStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          formatButtonVisible: false,
          titleCentered: true,
          headerPadding: const EdgeInsets.only(bottom: 8, top: 0),
          headerMargin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              // color: AppColors.punchOut,
              border: Border(
                  bottom: BorderSide(
                      width: 1.5, color: Theme.of(context).dividerColor)))),
      calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
              color: AppColors.colorAccent, shape: BoxShape.circle),
          // isTodayHighlighted: false,
          todayDecoration: BoxDecoration(
              color: AppColors.colorAccent.withOpacity(0.5),
              shape: BoxShape.circle),
          todayTextStyle: const TextStyle(color: Colors.white)),
    );
  }

  void _showBottomSheet(BuildContext mainContext) {
    List<PunchLogs> logsList = [];

    showModalBottomSheet(
      context: mainContext,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.34,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        // maxChildSize: logsList.length > 2 ? 0.95 : 0.3,
        expand: false,
        builder: (_, controller) => BlocProvider.value(
          value: BlocProvider.of<CalendarLogCubit>(mainContext),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<CalendarLogCubit, CalendarLogState>(
                  builder: (context, state) {
                    if (state is CalendarLogLoadingState) {
                      return const LoaderView();
                    }

                    if (state is CalendarLogLoadedState) {
                      if (state.punchLogs != null &&
                          state.punchLogs.data != null &&
                          state.punchLogs.data!.isNotEmpty) {
                        logsList = state.punchLogs.data as List<PunchLogs>;

                        return ListView.builder(
                          controller: controller,
                          itemCount: logsList.length + 1,
                          itemBuilder: (_, index) {
                            if (index != 0) {
                              return CalendarEventsItemView(
                                  logsItem: logsList.elementAt(index - 1));
                            }

                            return _headerView(
                                workingHrs: _calculateWorking(logsList),
                                notes: (logsList.isNotEmpty
                                    && logsList.first.notes.isNotEmpty)
                                    ? logsList.first.notes : null,
                                dayStatus: (logsList.isNotEmpty &&
                                    logsList.first.attendanceStatus!=null &&
                                    logsList.first.attendanceStatus!.isNotEmpty)
                                ? logsList.first.attendanceStatus : null,
                            );
                          },
                        );
                      }
                    }
                    return SingleChildScrollView(
                      controller: controller,
                      child: _headerView(message : (state is CalendarLogErrorState)
                          ? state.message
                          : "Marked absent on this date."),
                    );
                    /*return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                              AppHelper.dateFormat(
                                  date: _selectedDay, format: 'd MMMM y'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.largeValue),
                        ),
                        Container(
                          decoration: BoxDecorationX.panel,
                          margin: const EdgeInsets.all(15.0),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                                (state is CalendarLogErrorState)
                                    ? state.message
                                    : R.strings.txtNoAttendance,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .largeLabel
                                    .copyWith(color: AppColors.punchOut)),
                          ),
                        )
                      ],
                    );*/
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerView({String? message, String? workingHrs, String? notes, String? dayStatus}){
    bool isCorrection = false;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 6, horizontal: R.dimens.panelBoxLR),
      child: FutureBuilder<AuthResponse>(
          future: AuthService.instance.getCurrentUserData(),
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data?.user != null) {
              isCorrection = snapshot.data!.user?.isCorrection ?? false;
            }

            if(isCorrection){
              isCorrection = AppHelper.isTodayOrYesterday(_selectedDay);
            }
            // print("Harshit : isCorrection = $isCorrection");
          return Column(
            children: [
              SizedBox(width: double.infinity),
              const VerticalLine(
                  color: Colors.black12,
                  radius: 30.0,
                  width: 64,
                  height: 6),
              Padding(
                padding: const EdgeInsets.only(
                    top: 18.0, bottom: 18.0),
                child: Text(
                    AppHelper.dateFormat(
                        date: _selectedDay,
                        format: 'd MMMM y'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .largeValue),
              ),
              if(dayStatus!=null)
                Padding(
                  padding: const EdgeInsets.only(
                      top: 2.0, bottom: 12.0),
                  child: Text(dayStatus,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .largeLabel),
                ),
              if(isCorrection)
              const VerticalLine(
                  color: Colors.black12,
                  radius: 30.0,
                  width: double.infinity,
                  padding: EdgeInsets.zero,
                  height: 1),
              if(isCorrection)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Working Hours',
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .largeLabel),
                          Container(
                            width: 105,
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                                workingHrs ?? '00:00:00',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .largeValue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if(isCorrection)
                  CorrectionView(date: _selectedDay),
                ],
              ),
              const VerticalLine(
                  color: Colors.black12,
                  radius: 30.0,
                  width: double.infinity,
                  padding: EdgeInsets.zero,
                  height: 1),

            if(notes!=null && notes.isNotEmpty)
              Container(
                width: double.infinity,
                  decoration: BoxDecorationX.panelWithShadowR12,
                  margin: EdgeInsets.symmetric(vertical: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Notes : $notes", style: Theme.of(context).textTheme.mediumLabel,)
            ),

            if(message!=null && message.isNotEmpty)
              Container(
                width: double.infinity,
                decoration: BoxDecorationX.panel,
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .largeLabel
                          .copyWith(color: AppColors.punchOut)),
                ),
              )
            ],
          );
        }
      ),
    );
  }

  // Calculate the total duration
  String _calculateWorking(List<PunchLogs> logsList){
    Duration duration = logsList
        .map((record) => AppHelper.parseDuration(record.workingTime ?? "00:00:00"))
        .reduce((sum, element) => sum + element);

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }
}
