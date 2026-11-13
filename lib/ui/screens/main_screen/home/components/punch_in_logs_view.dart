import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/apis/repository/models/attendance_status.dart';
import '../../../../../core/config/config.dart';
import '../../../../../core/utils/server_time.dart';
import '../bloc/home_bloc.dart';

/// Today's punch log from WinHRMS `GET /api/attendance/today`
/// (one attendance row per day: punch in, punch out, break, total).
class PunchInLogsView extends StatelessWidget {
  const PunchInLogsView({super.key, this.animationController, this.animation});

  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      child: _getContentView(context),
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

  Widget _getContentView(BuildContext context) {
    return Padding(
      padding: PaddingC.boxPadding,
      child: Container(
        decoration: BoxDecorationX.panel,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 18.0, bottom: 15.0),
                child: Text(
                  R.strings.txtPunchLogsTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.mediumValue,
                )),
            const Divider(color: AppColors.black26),
            BlocConsumer<HomeBloc, HomeState>(
              // Sole place that routes to login on HomeUnAuthState.
              listener: (context, state) {
                if (state is HomeUnAuthState) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (r) => false);
                }
              },
              // Transient states: keep showing the last log.
              buildWhen: (_, current) =>
                  current is HomeLoadedState || current is HomeLoadingState,
              builder: (context, state) {
                if (state is HomeLoadingState) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                        child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }
                final HomeLoadedState? loaded =
                    state is HomeLoadedState ? state : null;
                return _log(context, loaded);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _log(BuildContext context, HomeLoadedState? state) {
    final AttendanceStatus? t = state?.today;
    final bool hasPunch = t != null && t.punchInAt != null;
    return Column(
      children: [
        _row(
          header: true,
          cells: [R.strings.txtPunchIn, R.strings.txtPunchOut, R.strings.txtDuration],
        ),
        if (!hasPunch)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Text(R.strings.msgNoRecordFound,
                style: const TextStyle(color: AppColors.lightGray)),
          )
        else ...[
          _row(cells: [
            _time(t.punchInAt),
            t.isPunchedOut
                ? _time(t.punchOutAt)
                : (t.isOnBreak ? "On break" : "Working"),
            _duration(state!.workedSecondsAt(DateTime.now())),
          ], icons: true, live: !t.isPunchedOut),
          if (t.breakSeconds > 0 || t.isOnBreak)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.free_breakfast_outlined,
                      size: 16, color: AppColors.lightGray),
                  const SizedBox(width: 6),
                  Text(
                    t.isOnBreak && t.breakStartedAt != null
                        ? "On break since ${_time(t.breakStartedAt)}"
                        : "Break: ${_duration(t.breakSeconds)}",
                    style:
                        const TextStyle(color: AppColors.lightGray, fontSize: 13),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _row({required List<String> cells, bool header = false,
      bool icons = false, bool live = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          for (int i = 0; i < cells.length; i++)
            Expanded(
              child: header
                  ? Text(cells[i],
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.colorAccent))
                  : icons && i < 2
                      ? VerticalIconText(
                          text: cells[i],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          svgPath: i == 0 ? R.icon.punchIn : R.icon.punchOut,
                          iconColor: i == 0 ? AppColors.punchIn : AppColors.punchOut)
                      : Text(
                          cells[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: live && i == 2
                                  ? AppColors.punchIn
                                  : AppColors.darkText),
                        ),
            ),
        ],
      ),
    );
  }

  /// Office (IST) clock time.
  static String _time(DateTime? t) => t == null
      ? " - "
      : DateFormat(AppConstants.dateFTime).format(ServerTime.toIst(t));

  static String _duration(int seconds) {
    final d = Duration(seconds: seconds < 0 ? 0 : seconds);
    return "${d.inHours.toString().padLeft(2, '0')}:"
        "${(d.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }
}
