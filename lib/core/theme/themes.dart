import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

import '../resources/colors.dart';

enum AppTheme { lightTheme, darkTheme }

class AppThemes {
  // final ThemeData lightTheme = ThemeData.light();
  // final ThemeData darkTheme = ThemeData.dark();
  static final appThemeData = {
    AppTheme.lightTheme: ThemeData.light().copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            }
        ),
        primaryColor: AppColors.colorPrimary,
        scaffoldBackgroundColor: AppColors.background,
        // backgroundColor: AppColors.white,
        dividerColor: AppColors.dividerColor,
        textTheme: ThemeData.light().textTheme
            .copyWith(bodyMedium: const TextStyle(fontSize: 12.0))
            .apply(fontFamily: 'Roboto', bodyColor: AppColors.black),
        iconTheme: ThemeData.light().iconTheme.copyWith(
            color: AppColors.black87,
            size: 20
        ),
        appBarTheme: ThemeData.light().appBarTheme.copyWith(
          backgroundColor: AppColors.background,
          elevation: 0.0,
          titleTextStyle: const TextStyle(
              color: AppColors.black,
              fontSize: 24,
              fontFamily: 'Metropolis',
              // fontFamily: "Roboto",
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700),
          iconTheme: const IconThemeData(color: AppColors.black),
          /*toolbarTextStyle: ThemeData.light().textTheme.copyWith(
                caption: const TextStyle(
                    color: AppColors.black,
                    fontSize: 18,
                    fontFamily: 'Metropolis',
                    fontWeight: FontWeight.w400)).bodyText2,*/
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          // onBackground: AppColors.black,
          // secondary: AppColors.black,
          // shadow: AppColors.shadowColor,
          // primary: AppColors.colorAccent,
          // onPrimary: AppColors.white,
          // surface: AppColors.white,
          // onSurface: AppColors.colorAccent,
        ),
        buttonTheme: ThemeData.light().buttonTheme.copyWith(
          minWidth: 36,
          buttonColor: AppColors.red,
        ),
        checkboxTheme: ThemeData.light().checkboxTheme.copyWith(
          checkColor: WidgetStateProperty.all(Colors.white),
          fillColor: WidgetStateProperty.all(AppColors.colorAccent),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
            textStyle: TextStyle(fontSize: 12.0)
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: AppColors.darkText),
          hintStyle: const TextStyle(color: AppColors.textLight), // Adjust hint font size
          helperStyle: const TextStyle(color: AppColors.textLight, fontSize: 10),
          errorStyle: const TextStyle(fontSize: 12.0),
          filled: true,
          fillColor: AppColors.white, // Global background color for all TextFormFields
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: AppColors.black)
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.colorAccent, width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.colorAccent, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          prefixIconColor: AppColors.white,
          prefixStyle: const TextStyle(color: AppColors.textLight),
          contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        ),
        bottomNavigationBarTheme: ThemeData.light().bottomNavigationBarTheme.copyWith(
          selectedItemColor: AppColors.colorAccent,
          unselectedItemColor: AppColors.black87,
          showSelectedLabels: true,
        )
      /*primaryColorLight: AppColors.lightGray,
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.red),
      bottomAppBarColor: AppColors.lightGray,
      backgroundColor: AppColors.background,
      dialogBackgroundColor: AppColors.backgroundLight,
      errorColor: AppColors.red,
      dividerColor: Colors.transparent,*/

    ),
    AppTheme.darkTheme: ThemeData.dark().copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }
      ),
      // primaryColor: AppColors.white,
      scaffoldBackgroundColor: Colors.red,
      /*primarySwatch: Colors.teal,
      backgroundColor: Colors.black,
      textTheme: const TextTheme(
        bodyText1: TextStyle(
          color: Colors.white,
        ),
      ),*/
    )
  };
}

extension PaddingC on Padding{
  static EdgeInsets get boxPadding {
    return const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 6.0,
        bottom: 6.0);
  }

  static EdgeInsets get innerBoxPadding{
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }
}

extension BoxDecorationX on BoxDecoration{

  /* common panel in used for all */
  static BoxDecoration get panel {
    return const BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    );
  }

  static BoxDecoration get panelTime => const BoxDecoration(
      color: AppColors.timeBox,
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    );

  static BoxDecoration get panelBorderB8 => BoxDecoration(
      color: AppColors.white,
      border: Border.all(color: AppColors.black12),
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    );


  static BoxDecoration get panelWithShadowR12 {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.2),
            offset: const Offset(0.1, 1.1),
            blurRadius: 1.0),
      ],
    );
  }

  static BoxDecoration get bottomBarWithShadow {
    return BoxDecoration(
      color: AppColors.bottomBar,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10.0),
        topRight: Radius.circular(10.0),
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.4),
            offset: const Offset(1.1, 1.1),
            blurRadius: 10.0),
      ],
    );
  }

}

extension CustomStyles on TextTheme {
  static const String fontName = 'Metropolis';

  TextStyle get panelHeadTitle {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.w500,
      fontSize: 18,
      letterSpacing: 0.5,
      color: AppColors.lightText,
    );
  }

  TextStyle get panelHeadRightLbl {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.normal,
      fontSize: 16,
      letterSpacing: 0.5,
    );
  }

  TextStyle get largeXXXLabel {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.normal,
      fontSize: 22,
      letterSpacing: -0.1,
      color: AppColors.textLight,
    );
  }

  TextStyle get largeXIXValue {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.w900,
      fontSize: 34,
      letterSpacing: -0.1,
      color: AppColors.darkText,
    );
  }

  TextStyle get largeXXXValue {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.w600,
      fontSize: 22,
      letterSpacing: -0.1,
      color: AppColors.darkText,
    );
  }
  TextStyle get largeXXLabel {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.normal,
      fontSize: 20,
      letterSpacing: -0.1,
      color: AppColors.textLight,
    );
  }

  TextStyle get largeXXValue {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: -0.1,
      color: AppColors.darkText,
    );
  }
  TextStyle get largeXLabel {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.normal,
      fontSize: 18,
      letterSpacing: -0.1,
      color: AppColors.textLight,
    );
  }

  TextStyle get largeXValue {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: -0.1,
      color: AppColors.darkText,
    );
  }
  TextStyle get largeLabel {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.normal,
      fontSize: 16,
      letterSpacing: -0.1,
      color: AppColors.textLight,
    );
  }

  TextStyle get largeValue {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: -0.1,
      color: AppColors.darkText,
    );
  }

  TextStyle get mediumLabel {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.normal,
      fontSize: 14,
      letterSpacing: -0.1,
      color: AppColors.textLight,
    );
  }

  TextStyle get mediumValue {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: -0.1,
      color: AppColors.darkText,
    );
  }

  TextStyle get smallLabel {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.normal,
      fontSize: 12,
      letterSpacing: -0.1,
      color: AppColors.textLight,
    );
  }

  TextStyle get smallValue {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.w600,
      fontSize: 12,
      letterSpacing: -0.1,
      color: AppColors.darkText,
    );
  }

  TextStyle get smallXLabel {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.normal,
      fontSize: 10,
      letterSpacing: -0.1,
      color: AppColors.textLight,
    );
  }

  TextStyle get smallXValue {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.w600,
      fontSize: 10,
      letterSpacing: -0.1,
      color: AppColors.darkText,
    );
  }

  TextStyle get buttonMin {
    return const TextStyle(
      fontFamily: fontName,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: -0.1,
      color: AppColors.white,
    );
  }
}






