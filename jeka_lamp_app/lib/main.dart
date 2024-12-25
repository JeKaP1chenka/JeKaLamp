import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/presentation/home_screen.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // providers: [],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}

class AppTheme {
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.grey[700],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.grey[850],
      
    )
  );

  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
  );
}
