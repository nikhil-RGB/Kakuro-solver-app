import 'dart:math';

import 'package:kakuro_solver/logic/KakuroBoard.dart';

class CellInfo {
  Point position;

  late int associated_hsum;
  late int associated_vsum;
  late List<Point> rightRun;
  late List<Point> downRun;
  late int
      horizontalRunIndex; //stores the index of this point in the horizontal run
  late int
      verticalRunIndex; //stores the index of this point in the horizontal run
  CellInfo({required this.position, required KakuroBoard board}) {
    if (position == const Point(-1, -1)) {
      throw InvalidCellException("-1,-1 is not a valid location");
    }
    String content =
        board.referenceBoard[position.x.toInt()][position.y.toInt()];
    if (content.contains(" ") || content == "-1") {
      throw InvalidCellException("Either a sum cell or a blocked cell");
    }
    //Valid reference cell
    List<Point>? tempRrun;
    List<Point>? tempVrun;
    //Find the horizontal run
    ROW_LOOP:
    for (int left = position.y.toInt() - 1; left >= 0; --left) {
      String content = board.referenceBoard[position.x.toInt()][left];
      if (content.contains(" ")) {
        Point hsum_loc = Point(position.x.toInt(), left);
        this.associated_hsum = int.parse(board
            .referenceBoard[hsum_loc.x.toInt()][hsum_loc.y.toInt()]
            .split(" ")[0]);
        tempRrun = board.parseCell(hsum_loc)![0];
        break ROW_LOOP;
      }
    }

    //Find the vertical run
    COL_LOOP:
    for (int up = position.x.toInt() - 1; up >= 0; --up) {
      String content = board.referenceBoard[up][position.y.toInt()];

      if (content.contains(" ")) {
        Point vsum_loc = Point(up, position.y.toInt());
        this.associated_vsum = int.parse(board
            .referenceBoard[vsum_loc.x.toInt()][vsum_loc.y.toInt()]
            .split(" ")[1]);
        tempVrun = board.parseCell(vsum_loc)![1];
        break COL_LOOP;
      }
    }
    rightRun = (tempRrun == null) ? [] : tempRrun;
    downRun = (tempVrun == null) ? [] : tempVrun;
    horizontalRunIndex = rightRun.indexOf(position);
    verticalRunIndex = downRun.indexOf(position);
  }
  //debug print
  void debugPrint() {
    print(
        "Vertical Sum: $associated_vsum \n Horizontal sum: $associated_hsum \n ");
    print(
        "Vertical Run Points: ${downRun.toString()}\nHorizontal Run Points: ${rightRun.toString()}");
    print(
        "Vertical run index: $verticalRunIndex  \n Horizontal run index: $horizontalRunIndex");
  }
}

//an object of this class being thrown indicates that the cell is invalid for the current operation
class InvalidCellException implements Exception {
  String cause;
  InvalidCellException(this.cause);
}
