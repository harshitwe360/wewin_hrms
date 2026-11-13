import 'package:flutter/material.dart';

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

}
