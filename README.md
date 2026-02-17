##  Kakuro Puzzle Solver

A high-performance Flutter&Dart application for automatically solving Kakuro puzzles using advanced constraint satisfaction and search techniques.
<br>
### Project Status:

The application is under active development. The core solving engine is built with Dart and is complete and optimized, with a Flutter-based UI in development.
<br>
### Solving Algorithm:

The solver implements a **cell-based MRV (Minimum Remaining Values) selection heurestic alongside a recursive DFS approach with backtracking** , significantly outperforming traditional run-based methods.
<br>
#### Core Components:

*   **`KakuroBoard.dart`**
    *   The central class representing the Kakuro puzzle grid with intelligent solving capabilities.
    *   **Cell-Based MRV Solver**: Implements a recursive depth-first search algorithm that:
        - Selects the most constrained cell first using **MRV (Minimum Remaining Values)** heuristic.
        - Examines the associated reference "sum" cell and computes possible digits using the `permuteSum` utility.
        - Branches only on valid digits (typically 2-5 options vs 20-50 in run-based approaches).
        - Performs **implicit forward checking** by validating digits against both horizontal and vertical runs simultaneously.
        - Uses **recursive backtracking** to explore the search space efficiently.
        - Returns `null` when a dead end is detected, triggering automatic backtracking.
    *   **Dual Implementation**: Provides both optimized recursive solver (`rsolve()`) and original iterative queue solver (`cellBasedSolve()`) for comparison
    *   The recursive approach uses **in-place board modification** with automatic backtracking, eliminating memory explosion issues

*   **`CellInfo.dart`**
    *   A class whose object stores all necessary information for each white, non-sum cell in the puzzle.
    *   Contains:
        - Cell position coordinates
        - Horizontal and vertical run cell lists
        - Associated sum values for both runs
        - Index positions within each run for quick digit extraction
    *   A ```HashMap<Point,CellInfo>``` object is precomputed once at startup via `buildReferenceMap()`, providing **O(1) access** to run information during solving

*   **`KakuroUtils.dart`**
    *   A utility class with static helper functions essential for the solver
    *   `permuteSum()`: Generates valid, unique-digit number combinations that sum to a specific value
    *   `constraintMatch()`: Validates combinations against existing numbers on the board
<br>

### 🎯 Key Optimizations

1. **MRV Heuristic**: Always selects the cell with fewest possible digits first, reducing branching factor significantly.
2. **Recursive Backtracking**: Eliminates queue overhead and memory explosion.
3. **Precomputed CellInfo**: O(1) access to run data vs O(n) parsing in original implementation
4. **In-Place Modification**: Single board reused throughout search, minimizing allocations
<br/>

###  Final Goal

The ultimate goal is a complete Flutter application where users can:

1.  Input or load a Kakuro puzzle into an interactive graphical interface.
2.  Trigger the solver with a single click.
3.  View the complete solution with run sum verification.
4.  Export/import puzzles for sharing(Planned future idea).

The project combines a **robust, optimized solving algorithm** with a **clean, intuitive user interface**.

---

*Built with Flutter & Dart • Contributions welcome!*
