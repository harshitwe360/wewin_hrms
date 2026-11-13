import 'package:attendance/core/apis/repository/models/attendance_status.dart';
import 'package:attendance/core/localization/app_localization.dart';
import 'package:attendance/ui/screens/main_screen/home/bloc/home_bloc.dart';
import 'package:attendance/ui/screens/main_screen/home/components/punch_in_logs_view.dart';
import 'package:attendance/ui/screens/main_screen/home/components/punch_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHomeBloc extends HomeBloc {
  void show(HomeState s) => emit(s);
}

AttendanceStatus _status({bool inn = false, bool out = false, bool onBreak = false,
        int breakSeconds = 0}) =>
    AttendanceStatus.fromJson({
      "attendance_date": "2026-11-13",
      "is_punched_in": inn,
      "is_punched_out": out,
      "is_on_break": onBreak,
      // Naive = IST wall clock, as the server sends it.
      "punch_in_at": inn || out ? "2026-11-13T09:30:00" : null,
      "punch_out_at": out ? "2026-11-13T18:15:00" : null,
      "break_seconds": breakSeconds,
      "elapsed_seconds": 100,
      "server_time": "2026-11-13T12:31:00Z",
    });

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppLocalization.instance.load(const Locale('en'));
  });

  Future<_FakeHomeBloc> pump(WidgetTester t, AttendanceStatus today) async {
    final bloc = _FakeHomeBloc();
    await t.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: BlocProvider<HomeBloc>.value(
                    value: bloc, child: const PunchView())))));
    bloc.show(HomeLoadedState(today: today, loadedAt: DateTime.now()));
    await t.pump();
    return bloc;
  }

  testWidgets('after punch-out, Punch In is offered again', (t) async {
    final bloc = await pump(t, _status(inn: true, out: true));
    expect(find.text('Punch In'), findsOneWidget);
    expect(find.textContaining('Punched out at'), findsOneWidget);
    expect(find.text('Punch Out'), findsNothing);
    await t.pumpWidget(const SizedBox()); // stops the clock ticker
    await t.runAsync(bloc.close);
  });

  testWidgets('before any punch, only Punch In', (t) async {
    final bloc = await pump(t, _status());
    expect(find.text('Punch In'), findsOneWidget);
    expect(find.textContaining('Punched out at'), findsNothing);
    await t.pumpWidget(const SizedBox()); // stops the clock ticker
    await t.runAsync(bloc.close);
  });

  testWidgets('while working, break and punch-out (no Punch In)', (t) async {
    final bloc = await pump(t, _status(inn: true));
    expect(find.text('Punch In'), findsNothing);
    expect(find.text('Punch Out'), findsOneWidget);
    await t.pumpWidget(const SizedBox()); // stops the clock ticker
    await t.runAsync(bloc.close);
  });

  group('Punch log (today from /attendance/today)', () {
    Future<_FakeHomeBloc> pumpLog(WidgetTester t, AttendanceStatus today) async {
      final bloc = _FakeHomeBloc();
      final ctrl = AnimationController(vsync: const TestVSync())..value = 1;
      await t.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: BlocProvider<HomeBloc>.value(
                      value: bloc,
                      child: PunchInLogsView(
                          animationController: ctrl, animation: ctrl))))));
      bloc.show(HomeLoadedState(today: today, loadedAt: DateTime.now()));
      await t.pump();
      return bloc;
    }

    Future<void> done(WidgetTester t, _FakeHomeBloc bloc) async {
      await t.pumpWidget(const SizedBox());
      await t.runAsync(bloc.close);
    }

    testWidgets('no punch yet', (t) async {
      final bloc = await pumpLog(t, _status());
      expect(find.text('No Records Found.'), findsOneWidget);
      await done(t, bloc);
    });

    testWidgets('punched out: IST times, total, break', (t) async {
      final bloc = await pumpLog(t, _status(inn: true, out: true, breakSeconds: 900));
      expect(find.text('09:30 AM'), findsOneWidget);
      expect(find.text('06:15 PM'), findsOneWidget);
      expect(find.text('00:01:40'), findsOneWidget, reason: 'elapsed_seconds=100');
      expect(find.text('Break: 00:15:00'), findsOneWidget);
      await done(t, bloc);
    });

    testWidgets('working: shows in time and Working', (t) async {
      final bloc = await pumpLog(t, _status(inn: true));
      expect(find.text('09:30 AM'), findsOneWidget);
      expect(find.text('Working'), findsOneWidget);
      await done(t, bloc);
    });
  });
}
