import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense/app/app.dart';

void main() {
  testWidgets('App loads splash screen test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    expect(find.byType(MyApp), findsOneWidget);
  });
}
