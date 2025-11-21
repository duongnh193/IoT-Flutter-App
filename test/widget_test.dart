// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_home_app/main.dart';

void main() {
  testWidgets('Dashboard renders summary', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartHomeApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tiếp Tục'), findsWidgets);
    expect(find.textContaining('Quản Lý Điện Năng'), findsOneWidget);
  });
}
