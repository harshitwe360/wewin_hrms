import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/apis/repository/models/attendance_status.dart';
import '../../../face_capture/face_capture_screen.dart';
import '../../../../../core/utils/server_time.dart';
import 'separated_clock.dart';
import '../bloc/home_bloc.dart';
import '../../../../../core/config/config.dart';

/// Today's timer and the punch / break actions (WinHRMS attendance).
class PunchView extends StatelessWidget {
  const PunchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.dimens.panelBoxB),
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) async {
          if (state is HomeBiometricRequiredState) {
            final HomeBloc bloc = context.read<HomeBloc>();
            final result = await FaceCaptureScreen.open(context, state.action);
            if (result != null) bloc.add(PunchCompletedEvent(result: result));
          } else if (state is HomeErrorState) {
            AppHelper.showSnackBar(context,
                snackBarMode: SnackBarMode.error, content: state.message);
          } else if (state is HomeLoadedState &&
              (state.actionMessage ?? "").isNotEmpty) {
            AppHelper.showSnackBar(context,
                snackBarMode: SnackBarMode.success,
                content: state.actionMessage!);
          }
        },
        // Error states are transient (the bloc re-emits the last data right
        // after), so keep showing the previous view for them.
        buildWhen: (previous, current) =>
            current is! HomeErrorState && current is! HomeBiometricRequiredState,
        builder: (context, state) {
          final HomeLoadedState? loaded =
              state is HomeLoadedState ? state : null;
          final AttendanceStatus? today = loaded?.today;
          final bool ticking =
              today != null && today.isWorking && !today.isOnBreak;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 135),
              ticking
                  ? StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, _) => SeparatedClock(
                          punchInSecCount:
                              loaded!.workedSecondsAt(DateTime.now())))
                  : SeparatedClock(
                      punchInSecCount:
                          loaded?.workedSecondsAt(DateTime.now()) ?? 0),
              if (today != null && today.isOnBreak)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(R.strings.txtOnBreak,
                      style: const TextStyle(
                          color: AppColors.punchOut,
                          fontWeight: FontWeight.w600)),
                ),
              const SizedBox(height: 24),
              state is HomeLoadingState
                  ? const LoaderView(
                      isDefaultLoader: true,
                      defaultColor: AppColors.punchButton,
                      margin: EdgeInsets.only(top: 12.0, bottom: 12))
                  : _actions(context, today),
            ],
          );
        },
      ),
    );
  }

  Widget _actions(BuildContext context, AttendanceStatus? today) {
    // Not working right now (never punched in today, or punched out):
    // offer Punch In again. After a punch-out the last out time is shown.
    if (today == null || !today.isWorking) {
      final DateTime? outAt = today?.isPunchedOut == true
          ? (today!.punchOutAt == null
              ? null
              : ServerTime.toIst(today.punchOutAt!))
          : null;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (outAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "Punched out at ${DateFormat(AppConstants.dateFTime).format(outAt)}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.lightGray, fontSize: 13),
              ),
            ),
          ButtonShort(
            onTap: () => _dispatch(context,
                PunchInOutEvent(punchType: PunchType.btnIn,
                    todayDate: AppHelper.dateFormat())),
            label: R.strings.btnStartWorking,
            backgroundColor: AppColors.punchIn,
          ),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children: [
        ButtonShort(
          onTap: () => _dispatch(context, BreakEvent(start: !today.isOnBreak)),
          label: today.isOnBreak
              ? R.strings.btnEndBreak
              : R.strings.btnStartBreak,
          backgroundColor: AppColors.punchButton,
        ),
        // Punch-out is only offered when not on break.
        if (!today.isOnBreak)
          ButtonShort(
            onTap: () => _dispatch(context,
                PunchInOutEvent(punchType: PunchType.btnOut,
                    todayDate: AppHelper.dateFormat())),
            label: R.strings.btnStopWorking,
            backgroundColor: AppColors.punchOut,
          ),
      ],
    );
  }

  Future<void> _dispatch(BuildContext context, HomeEvent event) async {
    final HomeBloc bloc = context.read<HomeBloc>();
    if (await NetworkManager().isConnectedToInternet()) {
      bloc.add(event);
    } else if (context.mounted) {
      AppHelper.showSnackBar(context,
          snackBarMode: SnackBarMode.error, content: R.strings.errAPINoNet);
    }
  }
}
