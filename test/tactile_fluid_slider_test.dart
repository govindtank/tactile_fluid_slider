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
    testWidgets(
        'renders horizontal slider with dual-layer inverted text masking',
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

      // Dual-layer text mask renders 2 text elements (unfilled track + clipped active fill)
      expect(find.text('50%'), findsNWidgets(2));
    });

    testWidgets('updates value on drag or seek gesture', (tester) async {
      double currentValue = 0.2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 56,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return TactileFluidSlider(
                      value: currentValue,
                      onChanged: (val) {
                        setState(() => currentValue = val);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final sliderFinder = find.byType(TactileFluidSlider);
      await tester.drag(sliderFinder, const Offset(60, 0));
      await tester.pumpAndSettle();

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

      expect(find.text('80 nits'), findsWidgets);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsWidgets);
    });
  });
}
