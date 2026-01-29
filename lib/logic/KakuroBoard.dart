// X * Y board
// Each tile will be filled with a String value:
// 0 - empty grid box, should be filled with a number
//-1 - blocked/blacked-out tile, no value inside
//X Y  represents a control box with a horizontal sum-RIGHT(X) and a vertical sum- DOWN(Y)
//If X or Y is -1 it means that either the right sum or vertical sum is invalid.
// ignore_for_file: unnecessary_this

import 'dart:collection';

import 'dart:math';

import 'package:kakuro_solver/logic/KakuroUtils.dart';
import 'package:kakuro_solver/models/CellInfo.dart';

void main() {
  runTimedSolveTest();
}

class KakuroBoard {
  int ROW_COUNT;
  int COLUMN_COUNT;
  List<List<String>> referenceBoard;

  KakuroBoard(
      {required this.referenceBoard,
      required this.ROW_COUNT,
      required this.COLUMN_COUNT});

  //This function parses a particular cell at point(row, column) in the board.
  //If the cell is anything but a cell with horizontal/vertical sums, null is returned.
  //If the cell has a horizontal sum, but not a vertical sum, or vice versa then the corresponding nested list will be <null>.
  //output format: [Right[Horizontal number1, Horizontal number 2],Down[Vertical number 1, Vertical number 2]]
  List<List<Point>?>? parseCell(Point location) {
    String content =
        this.referenceBoard[location.x.toInt()][location.y.toInt()];
    //Incorrect format to be a sum cell, return an empty list
    if (!content.contains(" ")) {
      return null;
    }
    List<List<Point>?>? result;
    int right_sum = int.parse(content.split(' ')[0]);
    int down_sum = int.parse(content.split(' ')[1]);
    if (right_sum == -1) {
      //No horizontal sum for this grid box
      result = [null, []];
    } else if (down_sum == -1) {
      //No vertical sum for this grid box
      result = [[], null];
    } else {
      result = [[], []];
    }
    List<Point>? rightPoints = result[0];
    List<Point>? downPoints = result[1];
    if (rightPoints != null) {
      //code for moving right and getting points.
      CELL_ITERATOR:
      for (int row = location.x.toInt(), col = location.y.toInt() + 1;
          col < COLUMN_COUNT;
          ++col) {
        //Check to make sure content is a standard number and not a blocked cell/sum cell
        String cell_content = this.referenceBoard[row][col];
        if (cell_content == "-1" || cell_content.contains(' ')) {
          break CELL_ITERATOR;
        }
        rightPoints.add(Point(row, col));
      }
    }
    if (downPoints != null) {
      //code for moving down and getting points.
      CELL_ITERATOR_DOWN:
      for (int row = location.x.toInt() + 1, col = location.y.toInt();
          row < ROW_COUNT;
          ++row) {
        String cell_content = this.referenceBoard[row][col];
        if (cell_content == "-1" || cell_content.contains(' ')) {
          break CELL_ITERATOR_DOWN;
        }
        downPoints.add(Point(row, col));
      }
    }
    return [rightPoints, downPoints];
  }

  //Clone the reference kakuro board, returns a new board
  //with the same elements but a different reference pointer.
  static KakuroBoard cloneBoard(KakuroBoard reference) {
    List<List<String>> newBoard = [];
    List<List<String>> referenceBoard = reference.referenceBoard;
    for (int i = 0; i < reference.ROW_COUNT; ++i) {
      newBoard.add([]);
      for (int j = 0; j < reference.COLUMN_COUNT; ++j) {
        newBoard[i].add(referenceBoard[i][j]);
      }
    }
    KakuroBoard clone = KakuroBoard(
        referenceBoard: newBoard,
        ROW_COUNT: reference.ROW_COUNT,
        COLUMN_COUNT: reference.COLUMN_COUNT);

    return clone;
  }

  //Prints the board for debugging
  printBoard() {
    for (var row in this.referenceBoard) {
      print(row.join("  "));
    }
  }

  //returns a map with data for every non sum cell
//cell data includes position, associated horizontal and vertical runs, alongside their sums
//Check CellInfo.dart for more information
  static LinkedHashMap<Point, CellInfo> buildReferenceMap(
      KakuroBoard refBoard) {
    LinkedHashMap<Point, CellInfo> referenceMap = LinkedHashMap();
    for (int i = 0; i < refBoard.ROW_COUNT; ++i) {
      for (int j = 0; j < refBoard.COLUMN_COUNT; ++j) {
        String content = refBoard.referenceBoard[i][j];
        if (content.contains(" ") || content == "-1") {
          continue;
        }
        Point cell_point = Point(i, j);
        CellInfo cell_info = CellInfo(board: refBoard, position: cell_point);
        referenceMap[cell_point] = cell_info;
      }
    }
    return referenceMap;
  }

//This function returns all the possible solutions to a particular
//cell after checking both horizontal and vertical runs, this function is
//crucial to the new solver function
  List<int> solveAt(CellInfo cell_info) {
    String row_constraint = "";
    String col_constraint = "";
    cell_info.rightRun.forEach((element) {
      row_constraint +=
          this.referenceBoard[element.x.toInt()][element.y.toInt()];
    });
    cell_info.downRun.forEach((element) {
      col_constraint +=
          this.referenceBoard[element.x.toInt()][element.y.toInt()];
    });
    List<int> horizontal_combns = (cell_info.associated_hsum == -1)
        ? []
        : KakuroUtils.permuteSum(cell_info.associated_hsum,
                cell_info.rightRun.length, row_constraint)
            .map((e) {
              String combn = e.toString();
              combn = combn[cell_info.horizontalRunIndex];
              return int.parse(combn);
            })
            .toSet()
            .toList();
    List<int> vertical_combns = (cell_info.associated_vsum == -1)
        ? []
        : KakuroUtils.permuteSum(cell_info.associated_vsum,
                cell_info.downRun.length, col_constraint)
            .map((e) {
              String combn = e.toString();
              combn = combn[cell_info.verticalRunIndex];
              return int.parse(combn);
            })
            .toSet()
            .toList();
    if (cell_info.associated_hsum == -1) {
      return vertical_combns;
    } else if (cell_info.associated_vsum == -1) {
      return horizontal_combns;
    } else if (vertical_combns.isEmpty || horizontal_combns.isEmpty) {
      return [];
    } else {
      return horizontal_combns
          .where((element) => vertical_combns.contains(element))
          .toList();
    }
  }

  //This function checks if a board is filled
  bool isBoardFilled() {
    for (int i = 0; i < this.ROW_COUNT; ++i) {
      for (int j = 0; j < this.COLUMN_COUNT; ++j) {
        String content = this.referenceBoard[i][j];
        if (content == "0") {
          return false;
        }
      }
    }
    return true;
  }

  //This function attempts to solve the board recursively, with a cell based
  //MRV approach
  KakuroBoard? solveRecursive(
      LinkedHashMap<Point, CellInfo> cellMap, int depth) {
    if (this.isBoardFilled()) return this;

    Point? target = this.mrvSelect(cellMap);
    if (target == const Point(-1, -1)) {
      return null;
    }

    List<int> possibleDigits = this.solveAt(cellMap[target]!);

    String originalValue =
        this.referenceBoard[target.x.toInt()][target.y.toInt()];

    for (int digit in possibleDigits) {
      this.referenceBoard[target.x.toInt()][target.y.toInt()] =
          digit.toString();

      KakuroBoard? result = this.solveRecursive(cellMap, depth + 1);

      if (result != null) {
        return result;
      }

      this.referenceBoard[target.x.toInt()][target.y.toInt()] = originalValue;
    }

    return null;
  }

  //Returns the location of the next cell to be solved for based on the
  //MRV heuristic(Minimum Remaining Values)
  Point mrvSelect(LinkedHashMap<Point, CellInfo> cellMap) {
    int min_choices = 20;
    Point min_location = Point(0, 0);
    for (MapEntry<Point, CellInfo> entry in cellMap.entries) {
      Point cell_location = entry.key;
      CellInfo cell_info = entry.value;
      String cell_content =
          this.referenceBoard[cell_location.x.toInt()][cell_location.y.toInt()];
      if (cell_content == "0") {
        int sols_count = this.solveAt(cell_info).length;
        if (sols_count == 0) {
          return const Point(-1, -1); // Immediate dead end
        }
        if (sols_count < min_choices) {
          min_choices = sols_count;
          min_location = cell_location;
        }
      }
    }
    return min_location;
  }

  //This function solves the board with a cell-based approach
  //instead of a run based one, whilst also employing MRV for
  //cell selection and forward checking.
  //This approach is iterative
  KakuroBoard cellBasedSolve() {
    LinkedHashMap<Point, CellInfo> cellMap =
        KakuroBoard.buildReferenceMap(this);
    List<KakuroBoard> boards = List.empty(growable: true);
    boards.add(this);
    while (boards.isNotEmpty) {
      KakuroBoard currentBoard = boards[0];
      if (currentBoard.isBoardFilled()) {
        return currentBoard;
      }
      Point target = currentBoard.mrvSelect(cellMap);
      List<int> solns = (target == const Point(-1, -1))
          ? []
          : currentBoard.solveAt(cellMap[target]!);
      List<KakuroBoard> sol_boards = List.empty(growable: true);
      for (int soln in solns) {
        KakuroBoard sol_b = KakuroBoard.cloneBoard(currentBoard);
        sol_b.referenceBoard[target.x.toInt()][target.y.toInt()] =
            soln.toString();
        sol_boards.add(sol_b);
      }
      boards.removeAt(0);
      boards.insertAll(0, sol_boards);
    }

    throw UnsolvableBoardException("No valid solutions found");
  }

  //Calls the recursive solve function after constructing the cell map.
  KakuroBoard rsolve() {
    LinkedHashMap<Point, CellInfo> cellMap =
        KakuroBoard.buildReferenceMap(this);
    KakuroBoard reference = KakuroBoard.cloneBoard(this);
    KakuroBoard? solution = reference.solveRecursive(cellMap, 0);
    if (solution == null) {
      throw UnsolvableBoardException("Board cannot be solved");
    }
    return solution;
  }
}

//an object of this class being thrown indicates that board is unsolvable
class UnsolvableBoardException implements Exception {
  String cause;
  UnsolvableBoardException(this.cause);
}

//Run a timed solve test
void runTimedSolveTest() {
  List<List<String>> testBoard9cross9 = [
    ["-1", "-1", "-1 10", "-1 33", "-1", "-1 15", "-1 10", "-1 12", "-1 22"],
    ["-1", "5 10", "0", "0", "27 27", "0", "0", "0", "0"],
    ["36 -1", "0", "0", "0", "0", "0", "0", "0", "0"],
    ["30 -1", "0", "0", "0", "0", "-1 22", "17 22", "0", "0"],
    ["-1", "-1", "30 -1", "0", "0", "0", "0", "-1", "-1"],
    ["-1", "-1 11", "12 20", "0", "0", "0", "0", "-1 8", "-1 6"],
    ["5 -1", "0", "0", "-1 5", "11 6", "0", "0", "0", "0"],
    ["38 -1", "0", "0", "0", "0", "0", "0", "0", "0"],
    ["15 -1", "0", "0", "0", "0", "13 -1", "0", "0", "-1"],
  ];

  List<List<String>> testBoard7cross7 = [
    ["-1", "-1", "-1 14", "-1 32", "-1 4", "-1 31", "-1"],
    ["-1", "21 12", "0", "0", "0", "0", "-1 17"],
    ["32 -1", "0", "5", "9", "3", "0", "0"],
    ["9 -1", "0", "0", "0", "12 19", "0", "8"],
    ["-1", "-1 12", "25 12", "0", "3", "0", "0"],
    ["31 -1", "9", "0", "0", "0", "0", "-1"],
    ["23 -1", "0", "0", "0", "0", "-1", "-1"]
  ];

  List<List<String>> testBoard8cross8 = [
    [
      "-1",
      "-1 25",
      "-1 30",
      "-1",
      "-1",
      "-1",
      "-1 17",
      "-1 12",
    ],
    [
      "15 -1",
      "9",
      "0",
      "-1 15",
      "-1 12",
      "12 25",
      "8",
      "0",
    ],
    [
      "33 -1",
      "0",
      "0",
      "0",
      "0",
      "0",
      "0",
      "0",
    ],
    [
      "22 -1",
      "2",
      "0",
      "0",
      "8",
      "0",
      "-1 18",
      "-1 17",
    ],
    [
      "16 -1",
      "0",
      "0",
      "6",
      "21 10",
      "0",
      "0",
      "0",
    ],
    [
      "5 -1",
      "0",
      "0",
      "18 11",
      "0",
      "0",
      "6",
      "0",
    ],
    [
      "25 -1",
      "0",
      "0",
      "0",
      "0",
      "0",
      "0",
      "-1",
    ],
    [
      "-1",
      "14 -1",
      "0",
      "0",
      "11 -1",
      "9",
      "0",
      "-1",
    ]
  ];

  List<List<String>> testBoardGrid = [
    ["-1", "-1", "-1", "-1 22", "-1 17"],
    ["-1", "-1", "16 19", "0", "0"],
    ["-1", "24 9", "0", "0", "0"],
    ["22 -1", "0", "0", "0", "-1"],
    ["5 -1", "0", "0", "-1", "-1"]
  ];
  KakuroBoard initialBoard = KakuroBoard(
      referenceBoard: testBoard8cross8, ROW_COUNT: 8, COLUMN_COUNT: 8);
  //Recursive solution

  print("\n\n Board passed to recursive based solve:\n");
  initialBoard.printBoard();
  Stopwatch rBasedSolve = Stopwatch()..start();
  KakuroBoard sol2 = initialBoard.rsolve();
  rBasedSolve.stop();
  print("Solution: \n");
  sol2.printBoard();
  print("\n${rBasedSolve.elapsed} time elapsed");

  //iterative solution
  // print("\n\n Board passed to cellBasedSolve:\n");
  // initialBoard.printBoard();
  // Stopwatch cellBasedSolve = Stopwatch()..start();
  // KakuroBoard sol1 = initialBoard.cellBasedSolve();
  // cellBasedSolve.stop();
  // print("Solution: \n");
  // sol1.printBoard();
  // print("\n${cellBasedSolve.elapsed} time elapsed");
}
