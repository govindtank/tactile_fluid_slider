import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tactile_fluid_slider/tactile_fluid_slider.dart';

void main() {
  group('TactileSliderTheme presets', () {
    test('instantiates valid color themes', () {
      final dark = TactileSliderTheme.dark();
      final light = TactileSliderTheme.light();
      final appleHome = TactileSliderTheme.appleHome();

      expect(dark.trackColor, isNotNull);
      expect(light.trackColor, isNotNull);
      expect(appleHome.trackColor, isNotNull);
    });
  });

  group('TactileFluidSlider Widget Tests', () {
    testWidgets('renders horizontal slider with embedded percentage',
        (tester) async {
      double currentValue = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 250,
                child: TactileFluidSlider(
                  value: currentValue,
                  onChanged: (val) => currentValue = val,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('updates value on drag gesture', (tester) async {
      double currentValue = 0.2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: TactileFluidSlider(
                  value: currentValue,
                  onChanged: (val) => currentValue = val,
                ),
              ),
            ),
          ),
        ),
      );

      final sliderFinder = find.byType(TactileFluidSlider);
      final center = tester.getCenter(sliderFinder);

      // Drag rightward
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(60, 0));
      await gesture.up();
      await tester.pump();

      expect(currentValue, greaterThan(0.2));
    });

    testWidgets('renders custom value formatter and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 250,
                child: TactileFluidSlider(
                  value: 0.8,
                  onChanged: (_) {},
                  icon: const Icon(Icons.wb_sunny_rounded),
                  valueFormatter: (v) => '${(v * 100).round()} nits',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('80 nits'), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
    });
  });
}
