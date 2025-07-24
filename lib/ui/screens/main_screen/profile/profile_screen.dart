import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/apis/repository/models/auth_response.dart';
import '../../../../core/config/config.dart';
import '../../login/bloc/login_bloc.dart';
import 'components/resign_view.dart';
import 'bloc/profile_bloc.dart';
import 'bloc/resign_cubit.dart';
import 'components/profile_label_value_down.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc()
            ..add(const GetUserDetails()),
        ),
        BlocProvider(
          create: (context) => ResignCubit(),
        ),
      ],
      child: FutureBuilder<AuthResponse>(
          future: AuthService.instance.getCurrentUserData(),
          builder: (context1, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoaderView();
            }

            if (snapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
              });
              return ErrorView(error: R.strings.errMsgUnableToShow);
            }

            if (!snapshot.hasData || snapshot.data?.user == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
              });
              return ErrorView(error: R.strings.errMsgUnableToShow);
            }

            if (snapshot.data != null && snapshot.data?.user != null) {
              AuthResponse auth = snapshot.data!;
              return SafeArea(
                child: BlocListener<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state is LoginLoadingState) {
                      LoadingDialog.show(context);
                    }
                    if (state is LoginFinishedState) {
                      LoadingDialog.hide(context);
                      if (state.isSuccess) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.login, (r) => false);
                      }
                    }
                    if (state is LoginErrorState) {
                      LoadingDialog.hide(context);
                      AppHelper.showSnackBar(context,
                          snackBarMode: SnackBarMode.error,
                          content: state.message.isEmpty
                              ? R.strings.errMsgLoginInvalid : state.message);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: CircleAvatar(
                                radius: 45.0,
                                backgroundImage: auth.user != null
                                    && auth.user?.photo != null
                                    ? NetworkImage("${auth.user!.photo}")
                                    : null,
                                backgroundColor: AppColors.colorAccent,
                                child: auth.user?.photo == null ? SvgPicture
                                    .asset(
                                    R.icon.userDark,
                                    width: 78, height: 78,
                                    semanticsLabel: R.strings.txtProfilePhoto,
                                    colorFilter: const ColorFilter.mode(
                                        AppColors.white, BlendMode.srcIn)
                                ) : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                              auth.user != null
                                  ? "${auth.user!.name}"
                                  : R.strings.txtUser,
                              style: const TextStyle(
                                  color: AppColors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold
                              )),
                          const SizedBox(height: 4),
                          Text(auth.user!.emailId ?? ""),

                          const SizedBox(height: 26),
                          /*BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, state) {
                              if (state is ProfileLoadedState) {
                                return ProfileLabelValueDown(
                                    isCircleIcon: false,
                                    leftPadding: 0,
                                    icon: Icons.business,
                                    label: R.strings.txtCompany,
                                    svgPath: R.icon.company,
                                    iconColor: AppColors.colorPrimary,
                                    value: state.tenantDetails.name ?? " - ");
                              }
                              return Container();
                            },
                          ),
                          BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, state) {
                              if (state is ProfileLoadedState) {
                                return ProfileLabelValueDown(
                                    isCircleIcon: false,
                                    leftPadding: 0,
                                    icon: Icons.business,
                                    label: R.strings.txtDomain,
                                    svgPath: R.icon.company,
                                    iconColor: AppColors.colorPrimary,
                                    value: state.tenantDetails.baseDomain ?? " - ");
                              }
                              return Container();
                            },
                          ),*/
                          ProfileLabelValueDown(
                              isCircleIcon: false,
                              leftPadding: 0,
                              icon: Icons.business,
                              label: R.strings.txtCompany,
                              svgPath: R.icon.company,
                              iconColor: AppColors.colorPrimary,
                              value: auth.user?.companyName ?? " - "),
                          ProfileLabelValueDown(
                              isCircleIcon: false,
                              leftPadding: 0,
                              svgPath: R.icon.designation,
                              iconColor: AppColors.black,
                              icon:
                              Icons.business_center_outlined,
                              label: "Branch Name",
                              value: auth.user?.branchName ?? " - "),
                          ProfileLabelValueDown(
                              isCircleIcon: false,
                              leftPadding: 0,
                              svgPath: R.icon.screenshotSvg,
                              iconColor: AppColors.black,
                              icon:
                              Icons.present_to_all,
                              label: "Process Name",
                              value: auth.user?.processName ?? " - "),
                          ProfileLabelValueDown(
                              isCircleIcon: false,
                              leftPadding: 0,
                              svgPath: R.icon.fieldTask,
                              iconColor: AppColors.black,
                              icon:
                              Icons.business_center_outlined,
                              label: "Location",
                              value: auth.user?.locationName ?? " - "),
                          /*ProfileLabelValueDown(
                              isCircleIcon: false,
                              leftPadding: 0,
                              svgPath: R.icon.designation,
                              iconColor: AppColors.black,
                              icon:
                              Icons.business_center_outlined,
                              label: R.strings.txtDesignation,
                              value: auth.user?.branchName ?? " - "),*/
                          /*ProfileLabelValueDown(
                              isCircleIcon: false,
                              leftPadding: 0,
                              svgPath: R.icon.team,
                              iconColor: AppColors.black,
                              icon: Icons
                                  .mobile_screen_share_outlined,
                              label: R.strings.txtTeam,
                              value:
                              auth.user?.workEmailId ?? " - "),*/
                          ProfileLabelValueDown(
                              isCircleIcon: false,
                              leftPadding: 0,
                              svgPath: R.icon.mobile,
                              iconColor: AppColors.black,
                              icon: Icons
                                  .mobile_screen_share_outlined,
                              label: R.strings.txtMobile,
                              value:
                              auth.user?.contactNo ?? " - "),
                          ProfileLabelValueDown(
                              isCircleIcon: false,
                              leftPadding: 0,
                              svgPath: R.icon.mobile,
                              iconColor: AppColors.black,
                              icon: Icons
                                  .mobile_screen_share_outlined,
                              label: "Alt. ${R.strings.txtMobile}",
                              value:
                              auth.user?.alternateNo ?? " - "),
                          ProfileLabelValueDown(
                              isCircleIcon: false,
                              leftPadding: 0,
                              svgPath: R.icon.email,
                              iconColor: AppColors.black,
                              icon: Icons.email_outlined,
                              label: R.strings.txtEmailID,
                              value: auth.user?.emailId ?? " - "),

                          const SizedBox(height: 12),
                          ResignView(),
                          const SizedBox(height: 12),
                          ButtonFull(
                            onTap: () {
                              context.read<LoginBloc>().add(const Logout());
                            },
                            label: R.strings.txtSignOut,
                            height: 52,
                            backgroundColor: AppColors.colorAccent2,
                            isShadow: false,
                            // svgPath: R.icon.signOutDark,
                            padding: const EdgeInsets.all(8),
                          ),
                          const SizedBox(height: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return Container(
                color: AppColors.white,
                width: double.infinity,
                height: double.infinity,
                child: const LoaderView());
          }),
    );
  }
}