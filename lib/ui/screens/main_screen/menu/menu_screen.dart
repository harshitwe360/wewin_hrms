import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/apis/repository/models/auth_response.dart';
import '../../../../core/config/config.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({required this.role, required this.auth, super.key});

  final RoleType role;
  final AuthResponse auth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: <Widget>[
        // _getItemView(context,
        //     svgPath: R.icon.attendanceSvg,
        //     label: R.strings.txtAttendance,
        //     onTap: () => Navigator.pushNamed(
        //         context,
        //         (role == RoleType.admin)
        //             ? AppRoutes.attendance
        //             : AppRoutes.singleAttendance)),
        // _getItemView(context,
        //     svgPath: R.icon.screenshotSvg,
        //     label: R.strings.txtScreenShot,
        //     onTap: () => Navigator.pushNamed(context,
        //         (role == RoleType.admin)
        //             ? AppRoutes.screenShotUser
        //             : AppRoutes.screenShotList,
        //         arguments: Identity(
        //             id: auth.user?.userId ?? "0",
        //             email: auth.user?.email,
        //             firstName: auth.user?.firstName,
        //             lastName: auth.user?.lastName
        //         )
        //     )
        // ),
      ],
    ));
  }

  Widget _getItemView(BuildContext context,
      {String? svgPath, required String label, required Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecorationX.panelBorderB8,
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(4.0),
              decoration: const BoxDecoration(
                color: AppColors.iconBg,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: svgPath != null && svgPath.isNotEmpty
                    ? SvgPicture.asset(svgPath,
                        colorFilter: const ColorFilter.mode(
                            AppColors.colorAccent, BlendMode.srcIn),
                        semanticsLabel: label)
                    : const Icon(Icons.person, color: AppColors.black),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  label,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.largeValue,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.keyboard_arrow_right, color: AppColors.black54),
            )
          ],
        ),
      ),
    );
  }
}
