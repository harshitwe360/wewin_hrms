import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/config/config.dart';

class MyApp extends StatelessWidget {
  final String? startRoute;
  const MyApp({super.key, this.startRoute});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (BuildContext context, ThemeState themeState) {
          return MultiBlocProvider(
            providers: BlocProviders.providers,
            child: BlocBuilder<LocaleCubit, LocaleState>(
              buildWhen: (previousState, currentState) =>
                  previousState != currentState,
              builder: (_, localeState) {
                return MaterialApp(
                  initialRoute: startRoute ?? AppRoutes.launch,
                  debugShowCheckedModeBanner: false,
                  onGenerateRoute: AppRoutes.generateRoute,
                  onUnknownRoute: AppRoutes.onUnknownRoute,
                  locale: localeState.locale, //default set in locale_cubit.dart
                  supportedLocales: AppLocalizationSetup.supportedLocales,
                  localizationsDelegates:
                      AppLocalizationSetup.localizationDelegates,
                  localeResolutionCallback:
                      AppLocalizationSetup.localeResolutionCallback,
                  theme: themeState.themeData,
                );
              },
            ),
          );
        },
      ),
    );
  }
}