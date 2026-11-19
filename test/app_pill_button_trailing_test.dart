import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/core/widgets/calm_widgets.dart';

void main() {
  testWidgets('compact pill button fits a ListTile trailing slot', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            // Matches the bottom-sheet tile width from the reported crash.
            width: 406,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              title: const Text('Bubur ayam'),
              subtitle: const Text('320 kkal'),
              trailing: AppPillButton(
                label: 'Pilih',
                height: 36,
                expanded: false,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Pilih'), findsOneWidget);
  });
}
