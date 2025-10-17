import 'dart:math';

void main() {
  KakuroUtils.runTest(23, 3, "006");
}

//This class contains static utility functions for generating valid number sequences to be filled into
//a Kakuro board prior to and during it's DFS analysis.
class KakuroUtils {
  //tester fn for class KakuroUtils in lib/logic
  static void runTest(int sum, int gboxes, String constraint) {
    List<int> seqs = permuteSum(sum, gboxes, constraint);
    print(
        "number of sequences for sum $sum with $gboxes digits and matching $constraint are ${seqs.length} in number: \n");
    for (int seq in seqs) {
      print("$seq \n");
    }
  }

  //Returns a list of number sequences each of whose digits add up to sum, have g_boxes number of digits and
  //match constraint 'constraint'. Constraints are sequences already present on the board. 0 is a constraint number
  //serves as a placeholder for 'empty'.
  static List<int> permuteSum(int sum, int gboxes, String constraint) {
    if (!isValidSequence(int.parse(constraint.replaceAll("0", "")))) {
      //Constraint is invalid, throw the associated board out of eval by immediately returning an empty list.

      return [];
    }
    List<int> seqs = [];
    String mins = "";
    String maxs = "";
    for (int i = 0; i < gboxes; ++i) {
      mins += "1";
      maxs += "9";
    }

    int min = int.parse(mins);
    int max = int.parse(maxs);
    SEQUENCE_ITERATOR:
    for (; min < max; ++min) {
      if (min.toString().contains("0")) {
        continue SEQUENCE_ITERATOR;
      }
      if ((sum == summation(min)) &&
          constraintMatch(constraint, min) &&
          isValidSequence(min)) {
        //add valid sequences here
        seqs.add(min);
      }
    }
    return seqs;
  }

//True if no repeat-digits are found and sequence is valid(no zeros)
//False is all other cases.
  static bool isValidSequence(int num) {
    String nums = num.toString();
    if (nums.contains("0")) {
      //invalid sequence,return false
      return false;
    }

    for (int i = 0; i < nums.length; ++i) {
      String s = nums[i];
      if (nums.indexOf(s) != nums.lastIndexOf(s)) {
        return false;
      }
    }
    return true;
  }

//Sum of digits
  static int summation(int number) {
    int sum = 0;
    for (; number != 0; number = (number / 10).truncate()) {
      int digit = number % 10;
      sum += digit;
    }
    return sum;
  }

  //Exp digits cannot be 0.
  //Exp digits are the suggestion sequence, control is the constraint sequence, 0 indicates an empty box.eg: 090
  //true: constraint matches
  //false: no match, reject experiment sequence.
  static bool constraintMatch(String control, int experiment) {
    if (control.length != experiment.toString().length) {
      return false;
    }
    while (control.isNotEmpty) {
      int cont_dig = int.parse(control[control.length - 1]);
      int exp_dig = (experiment % 10);
      if ((cont_dig != exp_dig) && (cont_dig != 0)) {
        return false;
      }
      control = control.substring(0, control.length - 1);
      experiment = (experiment / 10).truncate();
    }
    return true;
  }
}
