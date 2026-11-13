import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../../core/config/config.dart';
import '../../../../../core/apis/repository/models/attendance_correction.dart';
import '../../../../../core/apis/repository/models/monthly_attendance.dart';
import '../../../../../core/utils/server_time.dart';
import '../bloc/calendar_cubit.dart';
import '../bloc/correction_cubit.dart';
import 'correction_view.dart';

/// Colour + label for each day status (calendar markers, legend, sheet).
class DayStyle {
  const DayStyle(this.label, this.color);

  final String label;
  final Color color;

  static DayStyle of(DayStatus s) => switch (s) {
        DayStatus.present => const DayStyle("Present", AppColors.punchIn),
        DayStatus.absent => const DayStyle("Absent", AppColors.punchOut),
        DayStatus.leave => const DayStyle("Leave", AppColors.pending),
        DayStatus.holiday => const DayStyle("Holiday", AppColors.productive),
        DayStatus.weekOff => const DayStyle("Week off", AppColors.lightGray),
        DayStatus.upcoming => const DayStyle("Upcoming", AppColors.absent),
        DayStatus.noData => const DayStyle("No record", AppColors.absent),
      };
}

/// Monthly attendance calendar (WinHRMS `monthly-attendance`).
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

  static const List<DayStatus> _legend = [
    DayStatus.present,
    DayStatus.absent,
    DayStatus.leave,
    DayStatus.weekOff,
  ];

  @override
  void initState() {
    super.initState();
    context.read<CalendarCubit>().loadMonth(_focusedDay, userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      child: Padding(
        padding: PaddingC.boxPadding,
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0, top: 12),
          decoration: BoxDecorationX.panel,
          child: BlocConsumer<CalendarCubit, CalendarState>(
            listener: (context, state) {
              if (state is CalendarErrorState) {
                AppHelper.showSnackBar(context,
                    snackBarMode: SnackBarMode.error, content: state.message);
              } else if (state is CalendarUnAuthState) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (r) => false);
              }
            },
            builder: (context, state) {
              final CalendarLoadedState? loaded =
                  state is CalendarLoadedState ? state : null;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _calendar(loaded),
                  SizedBox(
                    height: 3,
                    child: state is CalendarLoadingState
                        ? const LinearProgressIndicator(minHeight: 3)
                        : null,
                  ),
                  const Divider(color: AppColors.black26, height: 1),
                  _summary(loaded),
                  if (state is CalendarErrorState)
                    TextButton.icon(
                      onPressed: () => context
                          .read<CalendarCubit>()
                          .loadMonth(_focusedDay, userId: widget.userId),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                    ),
                ],
              );
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

  Widget _summary(CalendarLoadedState? s) {
    final counts = s?.counts() ?? const <DayStatus, int>{};
    final double hours = s?.attendance.totalHoursWorked ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              for (final st in _legend)
                Expanded(child: _LegendItem(status: st, count: counts[st] ?? 0)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: AppColors.lightGray),
              const SizedBox(width: 6),
              Text("Total worked this month: ${_hours(hours)}",
                  style: const TextStyle(color: AppColors.darkGrey, fontSize: 13)),
              if ((counts[DayStatus.holiday] ?? 0) > 0) ...[
                const SizedBox(width: 10),
                Text("· ${counts[DayStatus.holiday]} holiday",
                    style: const TextStyle(
                        color: AppColors.productive, fontSize: 13)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendar(CalendarLoadedState? s) {
    return TableCalendar<DayStatus>(
      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
        context
            .read<CalendarCubit>()
            .loadMonth(focusedDay, userId: widget.userId);
      },
      availableGestures: AvailableGestures.horizontalSwipe,
      eventLoader: (day) {
        if (s == null || day.month != s.month.month) return const [];
        final st = s.statusFor(day);
        return (st == DayStatus.upcoming || st == DayStatus.noData)
            ? const []
            : [st];
      },
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        if (s != null && selectedDay.month == s.month.month) {
          _showDaySheet(context, selectedDay);
        }
      },
      weekNumbersVisible: false,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.now(),
      currentDay: DateTime.now(),
      focusedDay: _focusedDay,
      calendarBuilders: CalendarBuilders(
        singleMarkerBuilder: (context, date, status) => Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              color: DayStyle.of(status).color),
          width: 12.0,
          height: 4.0,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
        ),
      ),
      headerStyle: HeaderStyle(
          titleTextStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          formatButtonVisible: false,
          titleCentered: true,
          headerPadding: const EdgeInsets.only(bottom: 8, top: 0),
          headerMargin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 1.5, color: Theme.of(context).dividerColor)))),
      calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
              color: AppColors.colorAccent, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(
              color: AppColors.colorAccent.withValues(alpha: 0.5),
              shape: BoxShape.circle),
          todayTextStyle: const TextStyle(color: Colors.white)),
    );
  }

  void _showDaySheet(BuildContext mainContext, DateTime date) {
    final cubit = mainContext.read<CalendarCubit>();
    // The sheet is a new route: hand both cubits over explicitly.
    final CorrectionCubit correctionCubit = mainContext.read<CorrectionCubit>();
    showModalBottomSheet(
      context: mainContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => MultiBlocProvider(
          providers: [
            BlocProvider<CalendarCubit>.value(value: cubit),
            BlocProvider<CorrectionCubit>.value(value: correctionCubit),
          ],
          child: BlocBuilder<CalendarCubit, CalendarState>(
            builder: (context, state) {
              if (state is! CalendarLoadedState) {
                return const Center(child: CircularProgressIndicator());
              }
              return _DayDetails(
                controller: controller,
                date: date,
                state: state,
                onCorrectionSubmitted: cubit.refreshCorrections,
              );
            },
          ),
        ),
      ),
    );
  }

  static String _hours(double h) {
    final int mins = (h * 60).round();
    return "${mins ~/ 60}h ${(mins % 60).toString().padLeft(2, '0')}m";
  }
}

class _DayDetails extends StatelessWidget {
  const _DayDetails({
    required this.controller,
    required this.date,
    required this.state,
    required this.onCorrectionSubmitted,
  });

  final ScrollController controller;
  final DateTime date;
  final CalendarLoadedState state;
  final VoidCallback onCorrectionSubmitted;

  @override
  Widget build(BuildContext context) {
    final AttendanceDay? day = state.dayFor(date);
    final DayStatus status = state.statusFor(date);
    final DayStyle style = DayStyle.of(status);
    final holiday = state.holidayFor(date);
    final AttendanceCorrection? correction = state.correctionFor(date);
    final DateTime today = DateTime.now();
    final bool canCorrect = state.isOwn &&
        !DateTime(date.year, date.month, date.day)
            .isAfter(DateTime(today.year, today.month, today.day)) &&
        status != DayStatus.weekOff &&
        status != DayStatus.holiday;

    String time(DateTime? t) =>
        t == null ? "–" : DateFormat(AppConstants.dateFTime).format(ServerTime.toIst(t));

    return ListView(
      controller: controller,
      padding: EdgeInsets.symmetric(
          horizontal: R.dimens.panelBoxLR + 8, vertical: 12),
      children: [
        Center(
          child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(3))),
        ),
        const SizedBox(height: 16),
        Text(AppHelper.dateFormat(date: date, format: 'EEEE, d MMMM y'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.largeValue),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
                status == DayStatus.holiday && holiday != null
                    ? "${holiday.name}${holiday.isOptional ? ' (optional)' : ''}"
                    : status == DayStatus.leave
                        ? "Leave${day?.leaveStatus != null ? ' · ${day!.leaveStatus}' : ''}"
                            "${day?.isLwp == true ? ' · LWP' : ''}"
                        : style.label,
                style: TextStyle(
                    color: style.color == AppColors.absent
                        ? AppColors.darkGrey
                        : style.color,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        if ((day?.shiftTimeLabel ?? "").isNotEmpty) ...[
          const SizedBox(height: 8),
          Text("${day!.shiftLabel ?? 'Shift'} · ${day.shiftTimeLabel} (IST)",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.lightGray, fontSize: 13)),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecorationX.panel,
          child: Row(
            children: [
              _stat("Punch in", time(day?.punchInAt), AppColors.punchIn),
              _stat("Punch out", time(day?.punchOutAt), AppColors.punchOut),
              _stat(
                  "Worked",
                  day?.totalHours == null
                      ? "–"
                      : _CalendarViewState._hours(day!.totalHours!),
                  AppColors.darkGrey),
              _stat(
                  "Break",
                  (day?.breakSeconds ?? 0) == 0
                      ? "–"
                      : "${(day!.breakSeconds! / 60).ceil()}m",
                  AppColors.darkGrey),
            ],
          ),
        ),
        if (canCorrect || correction != null) ...[
          const SizedBox(height: 16),
          CorrectionView(
            date: date,
            day: day,
            existing: correction,
            onSubmitted: onCorrectionSubmitted,
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _stat(String label, String value, Color color) => Expanded(
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.lightGray, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      );
}

/// Dot + label + day count, sized to fit four across a phone.
class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.status, required this.count});

  final DayStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final style = DayStyle.of(status);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: style.color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(style.label,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.lightGray)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text("$count ${count == 1 ? 'day' : 'days'}",
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText)),
      ],
    );
  }
}
