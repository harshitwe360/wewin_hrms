import 'package:flutter/material.dart' show Locale, immutable;
import 'package:flutter_bloc/flutter_bloc.dart';

part 'locale_state.dart';

/// /* In view use -> AppLocalization.of(context).text("Title"),
/// * To change the language by button use ->
/// * BlocProvider.of<LocaleCubit>(context).toHindi(); */
class LocaleCubit extends Cubit<LocaleState> {
  // Passing an initial value (state) with a default 'Locale' to the super class.
  LocaleCubit() : super(const SelectedLocale(Locale('en', '')));

  // Once we call this method, the BlocBuilder<LocaleCubit>
  // in the 'app.dart' will rebuild the entire app with
  // the new emitted state that holds the 'hi' locale.
  void toHindi() => emit(const SelectedLocale(Locale('hi', '')));

  // Same as the previous method, but with the 'en' locale.
  void toEnglish() => emit(const SelectedLocale(Locale('en', '')));
}