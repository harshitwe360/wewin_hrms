import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint("=======> onError: $stackTrace");
    super.onError(bloc, error, stackTrace);
  }

  /*@override
  void onEvent(Bloc bloc, Object? event) {
    // print("=======> onEvent: $event");
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    // print("=======> onTransition: $transition");
    super.onTransition(bloc, transition);
  }*/

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint("=======> onChange: $change");
  }
}
