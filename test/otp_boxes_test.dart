import 'package:attendance/ui/widgets/otp_boxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<List<String>> pump(WidgetTester t, List<String> completed) async {
    final changes = <String>[];
    await t.pumpWidget(MaterialApp(
        home: Scaffold(
            body: OtpBoxes(
                onChanged: changes.add, onCompleted: completed.add))));
    return changes;
  }

  testWidgets('6 boxes; typing fills in order and completes', (t) async {
    final completed = <String>[];
    final changes = await pump(t, completed);
    expect(find.byType(TextField), findsNWidgets(6));
    for (var i = 0; i < 6; i++) {
      await t.enterText(find.byType(TextField).at(i), '${i + 1}');
      await t.pump();
    }
    expect(changes.last, '123456');
    expect(completed, ['123456']);
  });

  testWidgets('pasting a full code into the first box fills all', (t) async {
    final completed = <String>[];
    final changes = await pump(t, completed);
    await t.enterText(find.byType(TextField).first, '654321');
    await t.pump();
    expect(changes.last, '654321');
    expect(completed, ['654321']);
  });

  testWidgets('non-digits are ignored', (t) async {
    final changes = await pump(t, []);
    await t.enterText(find.byType(TextField).first, 'a');
    await t.pump();
    expect(changes, anyOf(isEmpty, everyElement('')));
  });
}
