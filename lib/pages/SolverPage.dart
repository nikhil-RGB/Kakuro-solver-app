// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kakuro_solver/logic/KakuroBoard.dart';

class SolverPage extends StatefulWidget {
  int rows;
  int columns;

  late KakuroBoard reference;
  SolverPage({super.key, required this.rows, required this.columns}) {
    reference = KakuroBoard(
        referenceBoard: List.generate(
          rows,
          (i) => List.generate(
            columns,
            (j) => "0",
          ),
        ),
        ROW_COUNT: rows,
        COLUMN_COUNT: columns);
  }
  SolverPage.buildFromBoard({super.key, required this.reference})
      : rows = reference.referenceBoard.length,
        columns = reference.referenceBoard[0].length;
  @override
  State<SolverPage> createState() => _SolverPageState();
}

class _SolverPageState extends State<SolverPage> {
  Point selectedTile = const Point(0, 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(child: buildKakuroGrid()),
      ),
    );
  }

  Widget buildKakuroGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        childAspectRatio: 1,
        shrinkWrap: true,
        crossAxisCount: widget.columns,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        children: List.generate(widget.columns * widget.rows, (index) {
          int row = (index / widget.columns).floor();
          int col = index % widget.columns;
          return kakuroTile(
            x: row,
            y: col,
          );
        }),
      ),
    );
  }

  Widget kakuroTile({
    required int x,
    required int y,
  }) {
    String content = widget.reference.referenceBoard[x][y];
    return InkWell(
      onTap: () {
        setState(() {
          selectedTile = Point(x, y);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF9CFFC9),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: (selectedTile.x.toInt() == x && selectedTile.y.toInt() == y)
                ? Colors.white
                : Colors.black,
            width: 1,
          ),
        ),
        child: Center(
            child: Text(
          content,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        )),
      ),
    );
  }
}
