import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../../../core/apis/repository/models/punch_logs.dart';
import 'separated_clock.dart';
import '../bloc/home_bloc.dart';
import '../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../core/config/config.dart';

class PunchView extends StatefulWidget{
  const PunchView({super.key});

  @override
  State<PunchView> createState() => _PunchViewState();
}

class _PunchViewState extends State<PunchView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(R.dimens.panelBoxB),
        child: containerView()
    );
  }

  Widget containerView() {
    return FutureBuilder<AuthResponse>(
        future: AuthService.instance.getCurrentUserData(),
        builder: (context, snapshot) {
          return BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) async {
              if (state is HomeErrorState) {
                AppHelper.showSnackBar(context,
                    snackBarMode: SnackBarMode.error, content: state.message);
                if(state.message == AppConstants.unAuthorization){
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
                }
              }
            },
            builder: (context, state) {
              List<PunchLogs> punchLogs = [];
              List<PunchLogs> punchStatus = [];
              double sec = 0;
              if (state is HomeLoadedState) {
                if (state.punchStatus != null && state.punchStatus?.data!=null) {
                  punchStatus = state.punchStatus!.data as List<PunchLogs>;
                  sec = AppHelper.timeToSeconds(time: punchStatus.first.workingTime);
                }
                if (state.punchLogs != null && state.punchLogs?.data.isNotEmpty) {
                  punchLogs = state.punchLogs!.data as List<PunchLogs>;
                }
              }

              final bool isPunchIn = punchStatus.isNotEmpty
                  && (punchStatus.last.inTime.isNotEmpty && punchStatus.last.inTime != "00:00:00")
                  && (punchStatus.last.outTime.isEmpty || punchStatus.last.outTime == "00:00:00");

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 135),
                  (punchLogs.isNotEmpty || punchStatus.isNotEmpty)
                      ? isPunchIn
                      ? StreamBuilder(
                      stream:
                      Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot1) {
                        sec += 1;
                        return SeparatedClock(punchInSecCount: sec.toInt());
                      })
                      : SeparatedClock(punchInSecCount: sec.toInt())
                      : const SeparatedClock(),
                  SizedBox(height: 24),
                  // Padding(
                  //   padding: const EdgeInsets.all(15.0),
                  //   child: Text(
                  //     "General 09:30 AM to 06:30 PM",
                  //     // (punchStatus.first. != null &&
                  //     //     snapshot.data?.user?.currentShift !=
                  //     //         null)
                  //     //     ? "${AppHelper.timeToAMPM(time: snapshot.data!.user!.currentShift!.startTime)} "
                  //     //     "TO ${AppHelper.timeToAMPM(time: snapshot.data!.user!.currentShift!.endTime)}"
                  //     //     : R.strings.txtShift,
                  //     style: Theme.of(context).textTheme.smallValue,
                  //   ),
                  // ),

                  (state is HomeLoadingState)
                      ? const LoaderView(isDefaultLoader: true,
                        defaultColor: AppColors.punchButton,
                        margin: EdgeInsets.only(top: 12.0, bottom: 12))
                      : _buildActionButton(isPunchIn, punchStatus),
                ],
              );
            },
          );
        });
  }

  Widget _buildActionButton(bool isPunchIn, List<PunchLogs> punchStatus) {
    return isPunchIn
        ? ButtonShort(
            onTap: () async {
              final isConnected = await NetworkManager().isConnectedToInternet();
              if (isConnected) {
                context.read<HomeBloc>().add(PunchInOutEvent(
                    punchType: PunchType.BtnOut,
                    todayDate: AppHelper.dateFormat(),
                    punchOutId: punchStatus.last.id.toString()));
              } else {
                _showInternetSnackBar();
              }
            },
            label: R.strings.btnStopWorking,
            backgroundColor: AppColors.punchOut,
          )
        : ButtonShort (
            onTap: () async {
              final isConnected = await NetworkManager().isConnectedToInternet();
              if (isConnected) {
                context.read<HomeBloc>().add(PunchInOutEvent(
                    punchType: PunchType.BtnIn,
                    todayDate: AppHelper.dateFormat()));
              } else{
                _showInternetSnackBar();
              }
            },
            label: R.strings.btnStartWorking,
            backgroundColor: AppColors.punchIn,
          );
  }

  void _showInternetSnackBar() {
    AppHelper.showSnackBar(context,snackBarMode: SnackBarMode.error, content: R.strings.errAPINoNet);
  }
}