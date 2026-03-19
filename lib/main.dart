import 'package:flutter/material.dart';
import 'package:kakuro_solver/logic/KakuroBoard.dart';
import 'package:kakuro_solver/pages/SolverPage.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
        useMaterial3: true,
      ),
      home: SolverPage.buildFromBoard(
        reference: KakuroBoard(
            referenceBoard: testBoard7cross7, ROW_COUNT: 7, COLUMN_COUNT: 7),
      ),
    );
  }
}
