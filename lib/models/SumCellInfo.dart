import 'dart:math';

import 'package:kakuro_solver/logic/KakuroBoard.dart';

class SumCellInfo {
  Point location;
  late int horizontal_sum; //-1 if empty
  late int vertical_sum; //-1 if empty
  late List<Point> right_points; //[] if empty
  late List<Point> down_points; //[] if empty
  SumCellInfo({required KakuroBoard board, required this.location}) {
    String cell_content =
        board.referenceBoard[location.x.toInt()][location.y.toInt()];
    if (!cell_content.contains(" ")) {
      throw UnsolvableBoardException(
          "${this.location.toString()} does not point to a sum cell\nCell content= $cell_content");
    }
    horizontal_sum = int.parse(cell_content.split(" ")[0]);
    vertical_sum = int.parse(cell_content.split(" ")[1]);
    List<List<Point>?> run_info = board.parseCell(location)!;
    right_points = (horizontal_sum == -1) ? [] : run_info[0]!;
    down_points = vertical_sum == -1 ? [] : run_info[1]!;
  }
}

//an object of this class being thrown indicates that a non-sum cell location was passed to a constructor
//of the SumCellInfo class
class UnsolvableBoardException implements Exception {
  String cause;
  UnsolvableBoardException(this.cause);
}
