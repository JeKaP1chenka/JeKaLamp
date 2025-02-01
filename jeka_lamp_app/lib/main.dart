import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/app_theme.dart';

import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_cubit.dart';
import 'package:jeka_lamp_app/presentation/home_screen/home_screen.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;
import 'package:jeka_lamp_app/presentation/home_screen/home_screen_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/alarm/alarm_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_cubit.dart';

void main() async {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EffectCubit>(create: (context) => di.s1<EffectCubit>()),
        BlocProvider<AlarmCubit>(create: (context) => di.s1<AlarmCubit>()),
        BlocProvider<HomeScreenCubit>(
            create: (context) => di.s1<HomeScreenCubit>()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
