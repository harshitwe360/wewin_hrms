import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color colorPrimary = Color(0xffcddfff);
  static const Color colorAccent = Color(0xff679bfb);
  static const Color colorAccent2 = Color(0xffcf1f60);
  static const Color punchBoxBg = Color(0x25c1d7ff);
  static const Color punchButton = Color(0xff1d115a);
  static const Color punchIn = Color(0xff679bfb);
  static const Color punchOut = Color(0xFFFF5777);
  static const Color floatBtn = Color.fromRGBO(43, 66, 82, 1.0);

  static const Color backgroundWhite = Colors.white;
  static const Color background = Color(0xFFDBE8FF);
  static const Color border = Color(0x40728B9B);
  static const Color borderLight = Color(0xFFFAF9F9);
  static const Color fieldBg = Color(0xFFF3F3F3);
  static const Color fieldBorder = Color(0xFFE3E3E3);

  static const Color present = Color(0xFF14B8A6);
  static const Color absent = Color(0xFFCFD8DC);
  static const Color timeBox = Color(0x200D99FF);
  static const Color bottomBar = Color(0xFFFAFAFA);
  static const Color searchField = Color(0xFFFBFBFB);
  static const Color reject = Color(0xFFFF5777);
  static const Color rejectLight = Color(0x3FFF5777);
  static const Color approve = Color(0xFF14B8A6);
  static const Color approveLight = Color(0xFFD8FBF4);
  static const Color pending = Color(0xFFBB7000);
  static const Color pendingLight = Color(0xFFFEF1DC);

  static const Color purple50 = Color(0xFFE5DFFF);
  static const Color red100 = Color(0xFFFFDDE4);
  static const Color yellow50 = Color(0xFFFFF1CC);

  static const Color lightGray = Color(0xFF9B9B9B);
  static const Color darkGrey = Color(0xFF313A44);
  static const Color iconBg = Color(0x1A65748B);

  static const Color filterIcon = Color(0xFF062030);
  static const Color filterLabelBox = Color(0xFFD7E0E5);
  static const Color filterBtnApply = Color(0xFF0D1F2B);

  static const Color productive = Color(0xff7B61FF);
  static const Color unProductive = Color(0xffbdb0ff);
  static const Color neutral = Color(0xFF9E9E9E);

  static const Color activeTime = Color(0xFF104ADF);
  static const Color activeIdleTime = Color(0xFFB3B3B3);

  static const Color wellUnderUtilized = Color(0xFFC7E4D4);
  static const Color wellHealthy = Color(0xFF33D77E);
  static const Color wellOverWorked = Color(0xFF0F6D5C);

  static const Color graphBgBar = Color(0xFF87A0E5);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF14141E);
  static const Color lightText = Color(0xFFAAAAAA);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color spacer = Color(0xFFF2F2F2);
  static const Color spacerDark = Color(0xFF020202);

  static const Color transparent = Colors.transparent;
  static const Color transparentBlack = Color(0x00000044);
  static const Color colorAppBar = Color(0xfff1f1f1);
  static const Color red = Colors.red;
  static const Color redLight = Color(0xffffcdd7);
  static const Color grey = Colors.grey;
  static const Color green = Colors.green;
  static const Color greenLight = Color(0xffdff0d8);
  static const Color white = Colors.white;
  static const Color bgVector = Color(0xFFF2F2F2);
  static const Color textLight = Color(0xFF7B7B7B);
  static const Color textDark = Color(0xFF253840);
  static const Color shadowColor = Color(0x5F3A5160);
  static const Color black = Colors.black;
  static const Color black12 = Colors.black12;
  static const Color black26 = Colors.black26;
  static const Color black38 = Colors.black38;
  static const Color black54 = Colors.black54;
  static const Color black87 = Colors.black87;
  static const Color grey200 = Color(0xffeeeeee);
  static const Color grey400 = Color(0xffe2e1e8);
  static const Color grey600 = Color(0xffc2c2c2);
  static const Color orange = Color(0xfff96d5b);
  static const Color titleTextColor = Color(0xff5a5d85);
  static const Color lightPurple = Color(0xffbdb0ff);
  static const Color yellow = Color(0xfffef3cd);
  static const Color headYellow = Color(0xffffb800);
  static const Color whiteDisable = Color(0x7cffffff);
  static const Color warning = Color(0xfff0a823);
  static const Color success = Color(0xff3c763d);


  static const Color dividerColor = Color(0xFFF2F3F8);
  static const Color expendedColor = Color(0xFFF1EFFF);

  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color nearlyDarkBlue = Color(0xFF2633C5);

  static const Color nearlyBlue = Color(0xFF00B6F0);
  static const Color nearlyBlack = Color(0xFF213333);

  static const String fontName = 'Metropolis';

  static const greenGradient = [
    Color.fromRGBO(223, 250, 92, 1),
    Color.fromRGBO(129, 250, 112, 1)
  ];

  static const redGradient = [
    Color.fromRGBO(255, 93, 91, 1),
    Color.fromRGBO(254, 154, 92, 1),
  ];
  static const orangeGradient = [
    Color.fromRGBO(251, 173, 86, 1),
    Color.fromRGBO(253, 255, 93, 1),
  ];
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}