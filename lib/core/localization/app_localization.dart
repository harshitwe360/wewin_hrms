import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalization {
  static final AppLocalization _singleton = AppLocalization._internal();

  AppLocalization._internal();

  static AppLocalization get instance => _singleton;

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization)!;
  }

  late Map<String, String> _localizedValues;

  Future<AppLocalization> load(Locale locale) async {
    if (kDebugMode) {
      print("Language code - ${locale.languageCode}");
    }
    String jsonStringValues = await rootBundle
        .loadString('assets/locale/localization_${locale.languageCode}.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));

    return this;
  }

  // static member to have simple access to the delegate from Material App
  static const LocalizationsDelegate<AppLocalization> delegate =
  _AppLocalizationsDelegate();

  String text(String key) {
      // print("Language - $key");
    return _localizedValues[key] ?? "$key not found";
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
    // return ['en', 'hi', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    return AppLocalization.instance.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) => false;
}

class AppLocalizationSetup{
  static const Iterable<Locale> supportedLocales = [
    Locale('en', ''),// English
    Locale('hi', ''),// Hindi
    // Locale('vi', ''), // Vietnamese
  ];

  static const Iterable<LocalizationsDelegate<dynamic>> localizationDelegates = [
    AppLocalization.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static Locale localeResolutionCallback(Locale? locale, Iterable<Locale> supportedLocales) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale!.languageCode &&
          supportedLocale.countryCode == locale.countryCode) {
        return supportedLocale;
      }
    }
    return supportedLocales.first;
  }
}
