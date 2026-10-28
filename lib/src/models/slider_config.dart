import 'package:flutter/material.dart';

/// Presentation mode for the numerical or formatted value indicator.
enum ValueDisplayMode {
  /// No value text is displayed.
  none,

  /// Displayed inside the slider track with inverted dual-layer text clipping.
  embedded,

  /// Floats above or beside the touch point during dragging.
  floating,

  /// Shows both embedded label and floating detail bubble.
  both,
}

/// Visual styling configuration for [TactileFluidSlider].
@immutable
class TactileSliderTheme {
  const TactileSliderTheme({
    required this.trackColor,
    required this.activeColor,
    required this.textColor,
    required this.bubbleColor,
    this.unfilledTextColor,
    this.filledTextColor,
    this.activeGradient,
    this.borderRadius = 18.0,
    this.trackHeight = 56.0,
    this.trackWidth = 56.0,
    this.expandOnDrag = true,
    this.fontFamily,
    this.boxShadow = const [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 10.0,
        offset: Offset(0, 4),
      ),
    ],
  });

  final Color trackColor;
  final Color activeColor;
  final Color textColor;
  final Color? unfilledTextColor;
  final Color? filledTextColor;
  final Gradient? activeGradient;
  final Color bubbleColor;
  final double borderRadius;
  final double trackHeight;
  final double trackWidth;
  final bool expandOnDrag;
  final String? fontFamily;
  final List<BoxShadow> boxShadow;

  Color get effectiveUnfilledTextColor =>
      unfilledTextColor ??
      (ThemeData.estimateBrightnessForColor(trackColor) == Brightness.dark
          ? Colors.white70
          : Colors.black87);

  Color get effectiveFilledTextColor => filledTextColor ?? textColor;

  /// Default iOS 18 Control Center style dark theme.
  factory TactileSliderTheme.dark() {
    return const TactileSliderTheme(
      trackColor: Color(0xFF27272A),
      activeColor: Color(0xFFFAFAFA),
      textColor: Color(0xFF18181B),
      unfilledTextColor: Color(0xFFA1A1AA),
      filledTextColor: Color(0xFF18181B),
      bubbleColor: Color(0xFF3F3F46),
      borderRadius: 18.0,
      trackHeight: 56.0,
      trackWidth: 56.0,
    );
  }

  /// Clean light theme.
  factory TactileSliderTheme.light() {
    return const TactileSliderTheme(
      trackColor: Color(0xFFE4E4E7),
      activeColor: Color(0xFF09090B),
      textColor: Colors.white,
      unfilledTextColor: Color(0xFF71717A),
      filledTextColor: Colors.white,
      bubbleColor: Color(0xFF09090B),
      borderRadius: 18.0,
      trackHeight: 56.0,
      trackWidth: 56.0,
    );
  }

  /// Apple Home vibrant amber accent theme.
  factory TactileSliderTheme.appleHome() {
    return const TactileSliderTheme(
      trackColor: Color(0xFF1C1917),
      activeColor: Color(0xFFF59E0B),
      activeGradient: LinearGradient(
        colors: [Color(0xFFD97706), Color(0xFFFBBF24)],
      ),
      textColor: Color(0xFF1C1917),
      unfilledTextColor: Color(0xFFA8A29E),
      filledTextColor: Color(0xFF1C1917),
      bubbleColor: Color(0xFF292524),
      borderRadius: 20.0,
      trackHeight: 56.0,
      trackWidth: 56.0,
    );
  }
}
