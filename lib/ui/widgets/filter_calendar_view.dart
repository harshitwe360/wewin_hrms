import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/apis/repository/models/filter_model.dart';
import '../../core/config/config.dart';

class FilterCalendarView extends StatefulWidget {
  const FilterCalendarView(
      {Key? key,
      this.animationController,
      this.animation,
      required this.filter,
      required this.callBack})
      : super(key: key);

  final AnimationController? animationController;
  final Animation<double>? animation;
  final FilterModel filter;
  final Function(DateTime, DateTime) callBack;

  @override
  State<FilterCalendarView> createState() => _FilterCalendarViewState();
}

class _FilterCalendarViewState extends State<FilterCalendarView>
    with AutomaticKeepAliveClientMixin {

  DateTime? _focusedDay = DateTime.now();
  DateTime? _selectedDate = DateTime.now();

  String label = "Today";

  @override
  void initState() {
    _selectedDate = _focusedDay = AppHelper.stringToDateTime(
        date: widget.filter.endDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.animationController != null
        ? AnimatedBuilder(
            animation: widget.animationController!,
            child: contentView(),
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                opacity: widget.animation!,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 30 * (1.0 - widget.animation!.value), 0.0),
                  child: child,
                ),
              );
            },
          )
        : contentView();
  }

  Widget contentView() {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.now(),
        // lastDay: DateTime.utc(2030, 3, 14),
        currentDay: _selectedDate ?? DateTime.now(),
        focusedDay: _focusedDay ?? DateTime.now(),
        rowHeight: 42,
        availableGestures: AvailableGestures.horizontalSwipe,
        calendarFormat: CalendarFormat.week,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDate, selectedDay)) {
            widget.callBack(selectedDay, focusedDay);
            setState(() {
              _selectedDate = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        headerStyle: HeaderStyle(
            titleTextStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronVisible: false,
            rightChevronVisible: false,
            leftChevronPadding: EdgeInsets.symmetric(
                horizontal: 0, vertical: R.dimens.panelBoxT),
            rightChevronPadding: EdgeInsets.symmetric(
                horizontal: 0, vertical: R.dimens.panelBoxT),
            headerPadding: const EdgeInsets.only(bottom: 12),
            headerMargin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
                // color: AppColors.punchOut,
                border: Border(
                    bottom: BorderSide(
                        width: 1.5, color: Theme.of(context).dividerColor)))),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontSize: 11),
          weekendStyle: TextStyle(fontSize: 11),
        ),
        calendarStyle: CalendarStyle(
            defaultTextStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            weekendTextStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            selectedDecoration: const BoxDecoration(
                color: AppColors.colorAccent, shape: BoxShape.circle),
            // isTodayHighlighted: false,
            todayDecoration: BoxDecoration(
                color: AppColors.colorAccent.withOpacity(0.5),
                shape: BoxShape.circle),
            todayTextStyle: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
