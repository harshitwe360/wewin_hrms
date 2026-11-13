import 'package:flutter_bloc/flutter_bloc.dart';

import 'themes.dart';
import 'theme_state.dart';

/// /* In view use -> AppLocalization.of(context).text("Title"),
/// * To change the dart mode by button use ->
/// * `context.read<ThemeBloc>().add(ThemeEvent(appTheme: AppTheme.darkTheme));`
/// * `BlocProvider.of<ThemeBloc>(context).add(ThemeEvent(appTheme: AppTheme.darkTheme));` */

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc()
      : super(ThemeState(
            themeData: AppThemes.appThemeData[AppTheme.lightTheme])) {
    on<ThemeEvent>((event, emit) =>
        emit(ThemeState(themeData: AppThemes.appThemeData[event.appTheme])));
  }
}

class ThemeEvent {
  final AppTheme appTheme;
  ThemeEvent({required this.appTheme});
}
