import 'package:flutter_test/flutter_test.dart';
import 'package:cradle_app/main.dart';

void main() {
  testWidgets('Cradle app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CradleApp());
    expect(find.byType(CradleApp), findsOneWidget);
  });
}
