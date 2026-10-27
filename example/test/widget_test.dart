import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('TactileSliderDemoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TactileSliderDemoApp());
    expect(find.text('tactile_fluid_slider'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
  });
}
