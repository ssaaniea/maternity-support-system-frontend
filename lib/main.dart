import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_frontend/providers/user_stage_provider.dart';
import 'package:project_frontend/providers/home_provider.dart';
import 'package:project_frontend/providers/caregiver_provider.dart';
import 'package:project_frontend/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserStageProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CaregiverProvider()),
      ],
      child: MaterialApp(
        title: 'Maternity Support',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
