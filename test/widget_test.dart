import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aac_app/main.dart';
import 'package:aac_app/providers/aac_provider.dart';

void main() {
  testWidgets('AAC app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AacProvider(),
        child: const AacApp(),
      ),
    );
    expect(find.text('AAC Board'), findsOneWidget);
  });
}
