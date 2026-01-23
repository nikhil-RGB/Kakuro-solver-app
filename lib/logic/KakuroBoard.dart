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
import 'package:kakuro_solver/models/SumCellInfo.dart';

void main() {
  // runSolveTest();
  runTimedSolveTest();
}

class KakuroBoard {
  int ROW_COUNT;
  int COLUMN_COUNT;
  List<List<String>> referenceBoard;
  Point parseLocation;
  KakuroBoard(
      {required this.referenceBoard,
      this.parseLocation = const Point(0, 0),
      required this.ROW_COUNT,
      required this.COLUMN_COUNT});

  //This function updates the parse point of the board to the next position
  //true for a successful operation, false in case of failure
  bool updateParsePoint() {
    int row = this.parseLocation.x.toInt();
    int col = this.parseLocation.y.toInt();
    if (row == ROW_COUNT - 1 && col == COLUMN_COUNT - 1) {
      return false;
    }
    Point result =
        (col + 1) < COLUMN_COUNT ? Point(row, ++col) : Point(++row, 0);
    this.parseLocation = result;
    return true;
  }

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
        parseLocation: reference.parseLocation,
        ROW_COUNT: reference.ROW_COUNT,
        COLUMN_COUNT: reference.COLUMN_COUNT);

    return clone;
  }

  //This function allows for filling in of sample board, allowing it
  //to act as the root node for a game tree, explored via depth first
  //search.
  //PS: This function is stinky POOPOO. It does not work correctly because isntead of correctly backtracking it just steamrolls though the i,j coords without examining all possible states.
  //I am very stupid, but am trying to fix this now.
  // List<List<String>> solveBoard() {
  //   List<List<List<String>>> boards = [];
  //   boards.add(this.referenceBoard);
  //   for (int i = 0; i < KakuroBoard.ROW_COUNT; ++i) {
  //     for (int j = 0; j < KakuroBoard.COLUMN_COUNT; ++j) {
  //       //Point location of cell to be evaluated
  //       Point parseLocation = Point(i, j);
  //       List<List<Point>?>? sumData = parseCell(parseLocation);
  //       if (sumData == null) {
  //         continue;
  //       }
  //       //board should be cloned since some sum diagonal data is present
  //       List<List<String>> newBoard = KakuroBoard.cloneBoard(boards[0]);
  //       boards.removeAt(0); //insert board here, then remove old one
  //       boards.insert(0, newBoard);
  //       List<List<List<String>>> rightBoards = [];
  //       List<List<List<String>>> finalBoards = [];
  //       //Next, fill in each combination into a clone and add it to
  //       //right boards, then use that as a base to fill in left combns.
  //       //Note: check for empty right boards list.
  //       if (sumData[0] != null) {
  //         int rightSum = int.parse(this.referenceBoard[i][j].split(" ")[0]);
  //         //fill in right sum data
  //         List<Point> rightCellPoints = sumData[0]!;
  //         String constraint = "";
  //         for (Point cellPoint in rightCellPoints) {
  //           constraint += boards[0][cellPoint.x as int][cellPoint.y as int];
  //         }
  //         List<int> rightData =
  //             KakuroUtils.permuteSum(rightSum, constraint.length, constraint);
  //         //filling in right hand side sum digits below!
  //         for (int combn in rightData) {
  //           List<List<String>> clonedBoard = KakuroBoard.cloneBoard(newBoard);
  //           String combination = combn.toString();
  //           for (int i = 0; i < combination.length; ++i) {
  //             String digit = combination[i];
  //             clonedBoard[rightCellPoints[i].x.toInt()]
  //                 [rightCellPoints[i].y.toInt()] = digit.toString();
  //           }
  //           rightBoards.add(clonedBoard);
  //         }
  //       }
  //       if (sumData[1] != null) {
  //         //fill in left sum data
  //         if (rightBoards.isEmpty) {
  //           //add original board so left data can be filled in
  //           rightBoards.add(newBoard);
  //         }
  //         int leftSum = int.parse(this.referenceBoard[i][j].split(" ")[1]);
  //         List<Point> leftCellPoints = sumData[1]!;
  //         String constraint = "";
  //         for (Point cellPoint in leftCellPoints) {
  //           constraint +=
  //               rightBoards[0][cellPoint.x as int][cellPoint.y as int];
  //         }
  //         List<int> leftData =
  //             KakuroUtils.permuteSum(leftSum, constraint.length, constraint);
  //         //clean here
  //         for (List<List<String>> rboard in rightBoards) {
  //           for (int combn in leftData) {
  //             List<List<String>> clonedBoard = KakuroBoard.cloneBoard(rboard);
  //             String combination = combn.toString();
  //             for (int i = 0; i < combination.length; ++i) {
  //               String digit = combination[i];
  //               clonedBoard[leftCellPoints[i].x.toInt()]
  //                   [leftCellPoints[i].y.toInt()] = digit.toString();
  //             }
  //             finalBoards.add(clonedBoard);
  //           }
  //         }
  //         boards.insertAll(0, finalBoards);
  //         //clean here
  //         //fill in left data via right boards here, nested loop shit
  //       } else {
  //         boards.insertAll(0, rightBoards);
  //       }
  //       rightBoards.clear();
  //       finalBoards.clear();
  //     }
  //   }
  //   return boards[0];
  // }

  //Function that checks if a board is fully solved and that the parse location is pointing
  //to the end.
  bool isSolved() {
    if ((parseLocation.x.toInt() != (this.ROW_COUNT - 1)) ||
        (parseLocation.y.toInt() != (this.COLUMN_COUNT - 1))) {
      return false;
    }
    for (int i = 0; i < ROW_COUNT; ++i) {
      for (int j = 0; j < COLUMN_COUNT; ++j) {
        String content = this.referenceBoard[i][j];
        if (content == "0") {
          return false;
        }
      }
    }
    return true;
  }

  //Function that solves the board
  static KakuroBoard solve(KakuroBoard original) {
    int runs = 0;
    List<KakuroBoard> boards = [];
    boards.add(cloneBoard(original));
    MAIN_LOOP:
    while (boards.isNotEmpty) {
      // keep solving
      // temporary error throw to inspect the infinite loop issue in larger boards
      // if (runs > 10000) {
      //   print("What the fuck is goin on here");
      //   throw "Stop this fucking shit lol";
      // }
      KakuroBoard currentBoard = boards[0];
      // print("Board under eval at run $runs");
      // currentBoard.printBoard();
      if (currentBoard.isSolved()) {
        return currentBoard;
      }
      List<List<Point>?>? sumData =
          currentBoard.parseCell(currentBoard.parseLocation);
      // print(
      //     "Parse location at run $runs is ${currentBoard.parseLocation} and data is ${sumData.toString()}");
      if (sumData == null) {
        // print("Not a sum cell at ${currentBoard.parseLocation}");
        ++runs;
        currentBoard.updateParsePoint();
        continue;
      }
      //board spot has sum data  present
      KakuroBoard newBoard = currentBoard;

      List<KakuroBoard> rightBoards = [];
      List<KakuroBoard> finalBoards = [];

      if (sumData[0] != null) {
        int rightSum = int.parse(newBoard
            .referenceBoard[newBoard.parseLocation.x.toInt()]
                [newBoard.parseLocation.y.toInt()]
            .split(" ")[0]);
        // print("Right sum at ${newBoard.parseLocation.toString()} is $rightSum");
        //fill in right sum data
        List<Point> rightCellPoints = sumData[0]!;
        String constraint = "";
        for (Point cellPoint in rightCellPoints) {
          constraint +=
              newBoard.referenceBoard[cellPoint.x as int][cellPoint.y as int];
          // print(
          //     "Constarint horizontal at ${newBoard.parseLocation}: $constraint");
        }
        List<int> rightData =
            KakuroUtils.permuteSum(rightSum, constraint.length, constraint);
        if (rightData.isEmpty) {
          boards.removeAt(0);
          continue MAIN_LOOP;
        }
        //filling in right hand side sum digits below!
        for (int combn in rightData) {
          KakuroBoard clonedBoard = KakuroBoard.cloneBoard(newBoard);
          String combination = combn.toString();
          for (int i = 0; i < combination.length; ++i) {
            String digit = combination[i];
            clonedBoard.referenceBoard[rightCellPoints[i].x.toInt()]
                [rightCellPoints[i].y.toInt()] = digit.toString();
          }
          rightBoards.add(clonedBoard);
        }
      }

      if (sumData[1] != null) {
        //fill in left sum data
        if (rightBoards.isEmpty) {
          //add original board so left data can be filled in
          rightBoards.add(newBoard);
        }
        int leftSum = int.parse(newBoard
            .referenceBoard[newBoard.parseLocation.x.toInt()]
                [newBoard.parseLocation.y.toInt()]
            .split(" ")[1]);
        List<Point> leftCellPoints = sumData[1]!;
        // print(
        //     "run $runs left sum data at ${newBoard.parseLocation.toString()} is ${leftCellPoints.toString()} with sum $leftSum");
        // String constraint = "";
        // for (Point cellPoint in leftCellPoints) {
        //   constraint += rightBoards[0].referenceBoard[cellPoint.x as int]
        //       [cellPoint.y as int];
        // }
        // List<int> leftData =
        //     KakuroUtils.permuteSum(leftSum, constraint.length, constraint);
        //clean here
        RB_LOOP:
        for (KakuroBoard rboard in rightBoards) {
          String constraint = ""; // << MOVED INSIDE
          for (Point cellPoint in leftCellPoints) {
            // CRITICAL CHANGE: Use 'rboard' instead of 'rightBoards[0]'
            constraint +=
                rboard.referenceBoard[cellPoint.x.toInt()][cellPoint.y.toInt()];
          }
          // print("constraint at ${newBoard.parseLocation} is $constraint");
          List<int> leftData = // << MOVED INSIDE
              KakuroUtils.permuteSum(leftSum, constraint.length, constraint);
          if (leftData.isEmpty) {
            continue RB_LOOP;
          }
          for (int combn in leftData) {
            KakuroBoard clonedBoard = KakuroBoard.cloneBoard(rboard);
            String combination = combn.toString();
            for (int i = 0; i < combination.length; ++i) {
              String digit = combination[i];
              clonedBoard.referenceBoard[leftCellPoints[i].x.toInt()]
                  [leftCellPoints[i].y.toInt()] = digit.toString();
            }
            finalBoards.add(clonedBoard);
          }
        }
        //update here
        finalBoards.forEach((element) {
          element.updateParsePoint();
        });
        boards.removeAt(0);
        boards.insertAll(0, finalBoards);

        //clean here
        //fill in left data via right boards here, nested loop shit
      } else {
        rightBoards.forEach((element) {
          element.updateParsePoint();
        });
        boards.removeAt(0);
        boards.insertAll(0, rightBoards);
      }
      rightBoards.clear();
      finalBoards.clear();
      ++runs;
    }
    throw UnsolvableBoardException("null return from solve method");
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
  //Replaces the isSolved() function for the cell-based MRV approach
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

  //Returns the location of the next cell to be solved for based on the
  //MRV heuristic(Minimum Remaining Values)
  Point mrvSelect(LinkedHashMap<Point, CellInfo> cellMap) {
    int min_choices = 20;
    Point min_location = Point(0, 0);
    cellMap.forEach((cell_location, cell_info) {
      String cell_content =
          this.referenceBoard[cell_location.x.toInt()][cell_location.y.toInt()];
      if (cell_content == "0") {
        int sols_count = this.solveAt(cell_info).length;
        if (sols_count < min_choices) {
          min_choices = sols_count;
          min_location = cell_location;
        }
      }
    });
    return min_location;
  }

  //This function solves the board with a cell-based approach
  //instead of a run based one, whilst also employing MRV for
  //cell selection and forward checking.
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
      List<int> solns = currentBoard.solveAt(cellMap[target]!);
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
}

//an object of this class being thrown indicates that board is unsolvable
class UnsolvableBoardException implements Exception {
  String cause;
  UnsolvableBoardException(this.cause);
}

void runSolveTest() {
  //In this function, I need to create an object of KakuroBoard with a valid initial referenceBoard:
  List<List<String>> testBoardGrid = [
    ["-1", "-1", "-1", "-1 22", "-1 17"],
    ["-1", "-1", "16 19", "0", "0"],
    ["-1", "24 9", "0", "0", "0"],
    ["22 -1", "0", "0", "0", "-1"],
    ["5 -1", "0", "0", "-1", "-1"]
  ];

  List<List<String>> complexTestBoard = [
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

  KakuroBoard initialBoard =
      KakuroBoard(referenceBoard: testBoardGrid, ROW_COUNT: 9, COLUMN_COUNT: 9);

  print("DEBUG INFO FOR CellInfo.dart:");

  //Testing solveAt() function-->
  CellInfo testobj = CellInfo(position: const Point(2, 2), board: initialBoard);
  testobj.debugPrint();
  print("\n\n");
  List<int> testSolns = initialBoard.solveAt(testobj);
  print(
      "All solutions at ${testobj.position.toString()} for h_sum ${testobj.associated_hsum} and v_sum ${testobj.associated_vsum} are \n ${testSolns}");
  //end testing and debugging for solveAt()
  print("\n\n--- Starting Kakuro Solver ---");
  print("Initial Board State:");

  for (var row in initialBoard.referenceBoard) {
    print(row.join("  "));
  }
  print("\n\n");

  try {
    KakuroBoard solvedBoard = initialBoard.cellBasedSolve();

    print("\n--- Solution Found! ---");
    // Print the entire solved grid for verification
    for (var row in solvedBoard.referenceBoard) {
      print(row.join("  "));
    }
  } on UnsolvableBoardException catch (e) {
    print("\n--- Solver finished: The board is unsolvable. ---");
    print("Reason: ${e.toString()}");
  }
  // } catch (e) {
  //   print("\n--- Invalid Board \n ${e.toString()} ---");
  //   print(e);
  // }
}

void runTimedSolveTest() {
  List<List<String>> testBoard7cross7 = [
    ["-1", "-1", "-1 14", "-1 32", "-1 4", "-1 31", "-1"],
    ["-1", "21 12", "0", "0", "0", "0", "-1 17"],
    ["32 -1", "0", "5", "9", "3", "0", "0"],
    ["9 -1", "0", "0", "0", "12 19", "0", "8"],
    ["-1", "-1 12", "25 12", "0", "3", "0", "0"],
    ["31 -1", "9", "0", "0", "0", "0", "-1"],
    ["23 -1", "0", "0", "0", "0", "-1", "-1"]
  ];

  List<List<String>> testBoardGrid = [
    ["-1", "-1", "-1", "-1 22", "-1 17"],
    ["-1", "-1", "16 19", "0", "0"],
    ["-1", "24 9", "0", "0", "0"],
    ["22 -1", "0", "0", "0", "-1"],
    ["5 -1", "0", "0", "-1", "-1"]
  ];
  KakuroBoard initialBoard = KakuroBoard(
      referenceBoard: testBoard7cross7, ROW_COUNT: 7, COLUMN_COUNT: 7);
  // print("Initial Board for original solve function: \n");
  // initialBoard.printBoard();
  // Stopwatch ogSolve = Stopwatch()..start();
  // KakuroBoard sol = KakuroBoard.solve(initialBoard);
  // ogSolve.stop();
  // print("Solution via original solve() function: ");
  // sol.printBoard();
  // print("\n${ogSolve.elapsed} time elapsed");

  //cell-based approach
  print("\n\n Board passed to cellBasedSolve:\n");
  initialBoard.printBoard();
  Stopwatch cellBasedSolve = Stopwatch()..start();
  KakuroBoard sol1 = initialBoard.cellBasedSolve();
  cellBasedSolve.stop();
  print("Solution: \n");
  sol1.printBoard();
  print("\n${cellBasedSolve.elapsed} time elapsed");
}
