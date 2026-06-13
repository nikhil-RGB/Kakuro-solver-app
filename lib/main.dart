import 'package:flutter/material.dart';
import 'package:kakuro_solver/WelcomePage.dart';
// import 'package:kakuro_solver/logic/KakuroBoard.dart';
// import 'package:kakuro_solver/pages/SolverPage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KakuroSolver',
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          contentPadding: EdgeInsets.only(top: 0.0, bottom: 0.0),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const WelcomePage(),
      // home: SolverPage.buildFromBoard(
      //   reference: KakuroBoard(
      //       referenceBoard: testBoard7cross7, ROW_COUNT: 7, COLUMN_COUNT: 7),
      // ),
    );
  }
}
