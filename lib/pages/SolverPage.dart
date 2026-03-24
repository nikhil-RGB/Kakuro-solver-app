// ignore_for_file: must_be_immutable
import 'package:gap/gap.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Offset _tapPosition = Offset.zero; //for pop up menu
  Point selectedTile = const Point(0, 0);
  //This controller is associated with the field value for empty cells
  TextEditingController controller_dvalues = TextEditingController();
  //The controllers below are linked to the horizontal and vertical values.
  TextEditingController controller_shorizontal = TextEditingController();
  TextEditingController controller_svertical = TextEditingController();
  //To get tap position for displaying pop up menu
  void _getTapPosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildKakuroGrid(),
                const Gap(20),
                buildInputPanel(),
              ],
            ),
          ),
        ),
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
      onTapDown: _getTapPosition,
      onLongPress: () {
        _showContextMenu(context, x, y, content);
      },
      onTap: () {
        // if (content == "-1") {
        //   return; //Ineligible click
        // }
        controller_dvalues.clear();
        controller_shorizontal.clear();
        controller_svertical.clear();
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
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
          children: <TextSpan>[
            TextSpan(text: right),
            const TextSpan(
                text: "R ",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            TextSpan(text: down),
            const TextSpan(
                text: 'D',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
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

  Widget buildInputPanel() {
    String current_content = widget.reference
        .referenceBoard[selectedTile.x.toInt()][selectedTile.y.toInt()];
    if (int.tryParse(current_content) != null &&
        int.tryParse(current_content) != -1) {
      //This means that the selected cell is empty
      //We have to build a text field that allows inputting a number into the
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Input digit here",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            const Gap(6.1),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: TextField(
                onSubmitted: (value) {
                  if (value == "") {
                    value = "0";
                  }
                  //code here to input the digit
                  setState(() {
                    widget.reference.referenceBoard[selectedTile.x.toInt()]
                        [selectedTile.y.toInt()] = value;
                    controller_dvalues.clear();
                  });
                },
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.cyanAccent),
                controller: controller_dvalues,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),
            ),
          ],
        ),
      );
    }
    //This panel should be rendered if the cell is a sum cell
    else if (current_content.contains(" ")) {
      //also remember to set controllers to clear at the correct time
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Input R-sum here",
                  style: TextStyle(color: Colors.cyanAccent),
                ),
                const Gap(6.1),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.cyanAccent),
                    controller: controller_shorizontal,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          //Second row, vertical sum value entry
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Input D-sum here",
                  style: TextStyle(color: Colors.cyanAccent),
                ),
                const Gap(6.1),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.cyanAccent),
                    controller: controller_svertical,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          ElevatedButton(
              onPressed: () {
                String right = (controller_shorizontal.text == "")
                    ? "-1"
                    : controller_shorizontal.text;
                String down = (controller_svertical.text == "")
                    ? "-1"
                    : controller_svertical.text;
                setState(() {
                  widget.reference.referenceBoard[selectedTile.x.toInt()]
                      [selectedTile.y.toInt()] = right + " " + down;
                  controller_svertical.clear();
                  controller_shorizontal.clear();
                });
              },
              child: const Text("Okay")),
        ],
      );
    }
    //Before placeholder return add functionality to build editing ui for sum cells.
    //Placeholder return
    return const SizedBox.shrink();
  }

  void _showContextMenu(
      BuildContext context, int x, int y, String content) async {
    final RenderObject? overlay =
        Overlay.of(context).context.findRenderObject();
    final result = await showMenu(
      color: Color.fromARGB(255, 150, 201, 255),
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 40, 40),
        Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
            overlay.paintBounds.size.height),
      ),
      items: processItems(x, y, content),
    );
  }

  //create pop ups as required by the cell in question
  List<PopupMenuItem> processItems(int x, int y, String content) {
    List<PopupMenuItem> popups = [
      PopupMenuItem(
        value: 'csum',
        child: const Text('Convert to Sum Cell'),
        onTap: () {
          setState(() {
            widget.reference.referenceBoard[x][y] = "0 0";
          });
        },
      ),
      PopupMenuItem(
        value: 'cblock',
        child: const Text('Block cell'),
        onTap: () {
          setState(() {
            widget.reference.referenceBoard[x][y] = "-1";
          });
        },
      ),
      PopupMenuItem(
        value: 'cog',
        child: const Text('Convert to standard cell'),
        onTap: () {
          setState(() {
            widget.reference.referenceBoard[x][y] = "0";
          });
        },
      ),
    ];

    if (int.tryParse(content) != null && int.tryParse(content) != -1) {
      //standard numeric cell
      return <PopupMenuItem>[popups[0], popups[1]];
    } else if (content == "-1") {
      return <PopupMenuItem>[popups[0], popups[2]];
    } else {
      //is already sum cell
      return <PopupMenuItem>[popups[1], popups[2]];
    }
  }
}
