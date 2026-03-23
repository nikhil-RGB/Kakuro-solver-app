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
      padding: const EdgeInsets.all(10.0),
      child: GridView.count(
        childAspectRatio: 1,
        shrinkWrap: true,
        crossAxisCount: widget.columns,
        crossAxisSpacing: 0.5,
        mainAxisSpacing: 0.5,
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
    Widget processed_content = processCellContent(content);
    return InkWell(
      onTap: () {
        if (content == "-1") {
          return; //Ineligible click
        }
        setState(() {
          selectedTile = Point(x, y);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: (content == "-1") ? Colors.grey : Color(0xFF9CFFC9),
          borderRadius: BorderRadius.circular(1),
          border: Border.all(
            color: (selectedTile.x.toInt() == x && selectedTile.y.toInt() == y)
                ? Colors.white
                : Colors.black,
            width: 1.5,
          ),
        ),
        child: Center(
          child: processed_content,
        ),
      ),
    );
  }

  Widget processCellContent(String content) {
    if (content.contains(" ")) {
      List<String> data = content.split(" ");
      String right = (data[0] == "-1") ? "0" : data[0];
      String down = (data[1] == "-1") ? "0" : data[1];
      Widget text_widget = RichText(
        text: TextSpan(
          text: null,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
          children: <TextSpan>[
            TextSpan(text: right),
            const TextSpan(
                text: " R ",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            TextSpan(text: down),
            const TextSpan(
                text: ' D ',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      );
      return text_widget;
    } else if (content == "-1") {
      return const Text("");
    } else if (content == "0") {
      return const Text("");
    }
    return Text(
      content,
      style: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }
}
