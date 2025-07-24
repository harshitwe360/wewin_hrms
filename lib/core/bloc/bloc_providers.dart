import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/screens/attendance/detail/bloc/correction_cubit.dart';
import '../../ui/screens/main_screen/home/bloc/home_bloc.dart';
import '../../ui/screens/main_screen/profile/bloc/resign_cubit.dart';
import '../localization/locale_cubit.dart';
import '../../ui/screens/login/bloc/login_bloc.dart';

class BlocProviders {
  static final List<BlocProvider> providers = [
    BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
    BlocProvider<ResignCubit>(create: (_) => ResignCubit()),
    BlocProvider<CorrectionCubit>(create: (_) => CorrectionCubit()),

    // BlocProvider<WorkspaceBloc>(create: (context) => WorkspaceBloc()),
    BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
    BlocProvider<HomeBloc>(create: (context) => HomeBloc()),
    // BlocProvider<CalendarBloc>(create: (context) => CalendarBloc()),
    // BlocProvider<CalendarLogBloc>(create: (context) => CalendarLogBloc()),
  ];
}
