import 'package:flutter/material.dart';
import 'package:kakuro_solver/pages/SolverPage.dart';

/// Brand palette, similar to Solver Page
const Color kAccentGreen = Color(0xFF9CFFC9);
const Color kClayTile = Color(0xFFBF8A78);
const List<int> _kSizeOptions = [4, 5, 6, 7, 8];

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const List<List<String?>> _logo = [
    ['K', 'A', null],
    [null, 'K', 'U'],
    ['R', 'O', null],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'kakuro.solver',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 64),
                _buildLogoGrid(),
                const SizedBox(height: 56),
                const Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                    children: [
                      TextSpan(text: 'Solve complex '),
                      TextSpan(
                          text: 'Kakuros.',
                          style: TextStyle(color: kAccentGreen)),
                      TextSpan(text: '\nWithin '),
                      TextSpan(
                          text: 'seconds.', style: TextStyle(color: kClayTile)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),
                ElevatedButton(
                  onPressed: () => showBoardSizeDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentGreen,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoGrid() {
    const double tile = 72;
    const double gap = 10;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _logo.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: gap / 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: row.map((letter) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: gap / 2),
                child: Container(
                  width: tile,
                  height: tile,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: letter == null ? kClayTile : kAccentGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: letter == null
                      ? null
                      : Text(
                          letter,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

void showBoardSizeDialog(BuildContext context) {
  int rows = 5;
  int columns = 5;

  showDialog(
    context: context,
    builder: (_) {
      final entries = _kSizeOptions
          .map((n) => DropdownMenuEntry<int>(
                value: n,
                label: '$n',
                style: MenuItemButton.styleFrom(foregroundColor: Colors.white),
              ))
          .toList();

      Widget sizeMenu(String label, int initial, ValueChanged<int> onPick) {
        return DropdownMenu<int>(
          width: 220,
          label: Text(label),
          initialSelection: initial,
          requestFocusOnTap: false,
          dropdownMenuEntries: entries,
          onSelected: (value) => onPick(value ?? initial),
          textStyle: const TextStyle(color: Colors.white, fontSize: 18),
          trailingIcon: const Icon(Icons.arrow_drop_down, color: kAccentGreen),
          selectedTrailingIcon:
              const Icon(Icons.arrow_drop_up, color: kAccentGreen),
          // The popup list background
          menuStyle: const MenuStyle(
            backgroundColor: MaterialStatePropertyAll(Color(0xFF2A2A2A)),
          ),
          // The field box0- fill, padding for the value, border, label:
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            labelStyle: const TextStyle(color: kAccentGreen),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kAccentGreen),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kAccentGreen, width: 2),
            ),
          ),
        );
      }

      return AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        surfaceTintColor: Colors.transparent,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: const Text('New puzzle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            sizeMenu('Rows', rows, (v) => rows = v),
            const SizedBox(height: 20), // gap between the two dropdowns
            sizeMenu('Columns', columns, (v) => columns = v),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentGreen,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SolverPage(rows: rows, columns: columns),
                ),
              );
            },
            child: const Text('Okay'),
          ),
        ],
      );
    },
  );
}
