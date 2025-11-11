# Kakuro Puzzle Solver

This is a work-in-progress application being built with Flutter and Dart to automatically solve Kakuro puzzles.

## Project Status

The foundational logic for representing and solving the puzzle is currently in development. The progress so far includes the implementation of the core backend components.

### Core Components Implemented:

*   **`KakuroBoard.dart`**
    *   A class designed to represent the Kakuro puzzle grid.
    *   Includes logic to parse the board, identifying sum-giving cells and the empty cells they govern (both horizontally and vertically).
    *   Contains the initial structure for the main `solveBoard` function, which will house the puzzle-solving algorithm.

*   **`KakuroUtils.dart`**
    *   A utility class containing static helper functions essential for the solver.
    *   Includes methods to generate valid, unique-digit number combinations that add up to a specific sum (`permuteSum`).
    *   Contains logic to validate these combinations against existing numbers already on the board (`constraintMatch`).

## Final Goal

The ultimate goal of this project is to create a complete and user-friendly Flutter application where a user can:

1.  Input or load a Kakuro puzzle into a graphical interface.
2.  Trigger the solver with the click of a button.
3.  View the final, solved puzzle board.

The project aims to combine a robust solving algorithm on the backend with a clean, intuitive user interface on the frontend.
