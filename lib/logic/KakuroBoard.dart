// 8 * 8 board
// Each tile will be filled with a String value:
// 0 - empty grid box, should be filled with a number
//-1 - blocked/blacked-out tile, no value inside
//X Y  represents a control box with a horizontal sum-RIGHT(X) and a vertical sum- DOWN(Y)
//If X or Y is -1 it means that either the right sum or vertical sum is invalid.
// ignore_for_file: unnecessary_this

import 'dart:math';

import 'package:kakuro_solver/logic/KakuroUtils.dart';

class KakuroBoard {
  static const int ROW_COUNT = 8;
  static const int COLUMN_COUNT = 8;
  List<List<String>> referenceBoard;
  KakuroBoard({required this.referenceBoard});
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
          col < 8;
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
          row < 8;
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
  static List<List<String>> cloneBoard(List<List<String>> referenceBoard) {
    List<List<String>> newBoard = [];
    for (int i = 0; i < KakuroBoard.ROW_COUNT; ++i) {
      newBoard.add([]);
      for (int j = 0; j < KakuroBoard.COLUMN_COUNT; ++j) {
        newBoard[i].add(referenceBoard[i][j]);
      }
    }
    return newBoard;
  }

  //This function allows for filling in of sample board, allowing it
  //to act as the root node for a game tree, explored via depth first
  //search.
  List<List<String>> solveBoard() {
    List<List<List<String>>> boards = [];
    boards.add(this.referenceBoard);
    for (int i = 0; i < KakuroBoard.ROW_COUNT; ++i) {
      for (int j = 0; j < KakuroBoard.COLUMN_COUNT; ++j) {
        //Point location of cell to be evaluated
        Point parseLocation = Point(i, j);
        List<List<Point>?>? sumData = parseCell(parseLocation);
        if (sumData == null) {
          continue;
        }
        //board should be cloned since some sum diagonal data is present
        List<List<String>> newBoard = KakuroBoard.cloneBoard(boards[0]);
        boards.removeAt(0); //insert board here, then remove old one
        boards.insert(0, newBoard);
        List<List<List<String>>> rightBoards = [];
        List<List<List<String>>> finalBoards = [];
        //Next, fill in each combination into a clone and add it to
        //right boards, then use that as a base to fill in left combns.
        //Note: check for empty right boards list.
        if (sumData[0] != null) {
          int rightSum = int.parse(this.referenceBoard[i][j].split(" ")[0]);
          //fill in right sum data
          List<Point> rightCellPoints = sumData[0]!;
          String constraint = "";
          for (Point cellPoint in rightCellPoints) {
            constraint += boards[0][cellPoint.x as int][cellPoint.y as int];
          }
          List<int> rightData =
              KakuroUtils.permuteSum(rightSum, constraint.length, constraint);
          //filling in right hand side sum digits below!
          for (int combn in rightData) {
            List<List<String>> clonedBoard = KakuroBoard.cloneBoard(newBoard);
            String combination = combn.toString();
            for (int i = 0; i < combination.length; ++i) {
              String digit = combination[i];
              clonedBoard[rightCellPoints[i].x.toInt()]
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
          int leftSum = int.parse(this.referenceBoard[i][j].split(" ")[1]);
          List<Point> leftCellPoints = sumData[1]!;
          String constraint = "";
          for (Point cellPoint in leftCellPoints) {
            constraint +=
                rightBoards[0][cellPoint.x as int][cellPoint.y as int];
          }
          List<int> leftData =
              KakuroUtils.permuteSum(leftSum, constraint.length, constraint);
          //clean here
          for (List<List<String>> rboard in rightBoards) {
            for (int combn in leftData) {
              List<List<String>> clonedBoard = KakuroBoard.cloneBoard(rboard);
              String combination = combn.toString();
              for (int i = 0; i < combination.length; ++i) {
                String digit = combination[i];
                clonedBoard[leftCellPoints[i].x.toInt()]
                    [leftCellPoints[i].y.toInt()] = digit.toString();
              }
              finalBoards.add(clonedBoard);
            }
          }
          boards.insertAll(0, finalBoards);
          //clean here
          //fill in left data via right boards here, nested loop shit
        } else {
          boards.insertAll(0, rightBoards);
        }
        rightBoards.clear();
        finalBoards.clear();
      }
    }
    return boards[0];
  }
}
