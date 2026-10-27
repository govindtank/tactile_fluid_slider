import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/slider_config.dart';

/// A modern, tactile thick fluid slider with boundary rubber-band squash physics,
/// stepped haptic detents, and floating value bubbles.
class TactileFluidSlider extends StatefulWidget {
  const TactileFluidSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.orientation = Axis.horizontal,
    this.valueDisplayMode = ValueDisplayMode.embedded,
    this.valueFormatter,
    this.hapticDetents = const [0.25, 0.5, 0.75, 1.0],
    this.icon,
    this.theme,
    this.enableHaptics = true,
  })  : assert(min <= max, 'min must be less than or equal to max'),
        assert(
            value >= min && value <= max, 'value must be between min and max');

  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final Axis orientation;
  final ValueDisplayMode valueDisplayMode;
  final String Function(double value)? valueFormatter;
  final List<double>? hapticDetents;
  final Widget? icon;
  final TactileSliderTheme? theme;
  final bool enableHaptics;

  @override
  State<TactileFluidSlider> createState() => _TactileFluidSliderState();
}

class _TactileFluidSliderState extends State<TactileFluidSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _recoilController;
  late Animation<double> _recoilAnimation;

  double _overscroll = 0.0;
  bool _isDragging = false;
  double _lastDetentCrossed = -1.0;

  @override
  void initState() {
    super.initState();
    _recoilController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..addListener(() {
        setState(() {
          _overscroll = _recoilAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _recoilController.dispose();
    super.dispose();
  }

  void _triggerHapticIfCrossed(double normValue) {
    if (!widget.enableHaptics || widget.hapticDetents == null) return;

    for (final detent in widget.hapticDetents!) {
      final diff = (normValue - detent).abs();
      if (diff < 0.03 && (_lastDetentCrossed - detent).abs() >= 0.03) {
        HapticFeedback.selectionClick();
        _lastDetentCrossed = detent;
        break;
      }
    }
  }

  void _handleDragStart(Offset localPos, Size size) {
    _recoilController.stop();
    setState(() => _isDragging = true);
    widget.onChangeStart?.call(widget.value);
    _updateValue(localPos, size);
  }

  void _handleDragUpdate(Offset localPos, Size size) {
    _updateValue(localPos, size);
  }

  void _handleDragEnd() {
    setState(() => _isDragging = false);
    widget.onChangeEnd?.call(widget.value);

    if (_overscroll != 0.0) {
      _recoilAnimation = Tween<double>(
        begin: _overscroll,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _recoilController,
          curve: Curves.easeOutBack,
        ),
      );
      _recoilController.forward(from: 0.0);
    }
  }

  void _updateValue(Offset localPos, Size size) {
    final isHorizontal = widget.orientation == Axis.horizontal;
    final totalLength = isHorizontal ? size.width : size.height;
    final currentPos = isHorizontal ? localPos.dx : (size.height - localPos.dy);

    double fraction = currentPos / totalLength;

    if (fraction < 0.0) {
      // Rubber-band resistance curve
      final rawOverscroll = currentPos;
      _overscroll = rawOverscroll / (1.0 + rawOverscroll.abs() * 0.015);
      fraction = 0.0;
    } else if (fraction > 1.0) {
      final rawOverscroll = currentPos - totalLength;
      _overscroll = rawOverscroll / (1.0 + rawOverscroll.abs() * 0.015);
      fraction = 1.0;
    } else {
      _overscroll = 0.0;
    }

    final newValue = widget.min + fraction * (widget.max - widget.min);
    final clamped = newValue.clamp(widget.min, widget.max);

    _triggerHapticIfCrossed(fraction);

    if (clamped != widget.value) {
      widget.onChanged(clamped);
    }
  }

  String _formatValue(double val) {
    if (widget.valueFormatter != null) {
      return widget.valueFormatter!(val);
    }
    final percentage =
        ((val - widget.min) / (widget.max - widget.min) * 100).round();
    return '$percentage%';
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = widget.theme ??
        (Theme.of(context).brightness == Brightness.dark
            ? TactileSliderTheme.dark()
            : TactileSliderTheme.light());

    final isHorizontal = widget.orientation == Axis.horizontal;
    final normValue = ((widget.value - widget.min) / (widget.max - widget.min))
        .clamp(0.0, 1.0);
    final formattedText = _formatValue(widget.value);

    // Dynamic squash calculation based on overscroll
    final stretchScale = 1.0 + (_overscroll.abs() / 250.0).clamp(0.0, 0.08);
    final squashScale = 1.0 - (_overscroll.abs() / 450.0).clamp(0.0, 0.05);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            isHorizontal ? constraints.maxWidth : activeTheme.trackWidth;
        final height =
            isHorizontal ? activeTheme.trackHeight : constraints.maxHeight;

        final fillLength = (isHorizontal ? width : height) * normValue;

        return GestureDetector(
          onPanStart: (d) =>
              _handleDragStart(d.localPosition, Size(width, height)),
          onPanUpdate: (d) =>
              _handleDragUpdate(d.localPosition, Size(width, height)),
          onPanEnd: (_) => _handleDragEnd(),
          onPanCancel: () => _handleDragEnd(),
          child: Transform.scale(
            scaleX: isHorizontal ? stretchScale : squashScale,
            scaleY: isHorizontal ? squashScale : stretchScale,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Track Container
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: activeTheme.trackColor,
                    borderRadius:
                        BorderRadius.circular(activeTheme.borderRadius),
                    boxShadow: activeTheme.boxShadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: isHorizontal
                        ? Alignment.centerLeft
                        : Alignment.bottomCenter,
                    children: [
                      // Active Filled Bar
                      AnimatedContainer(
                        duration: _isDragging
                            ? Duration.zero
                            : const Duration(milliseconds: 100),
                        width: isHorizontal ? fillLength : width,
                        height: isHorizontal ? height : fillLength,
                        decoration: BoxDecoration(
                          color: activeTheme.activeColor,
                          borderRadius:
                              BorderRadius.circular(activeTheme.borderRadius),
                        ),
                      ),
                      // Embedded Label & Icon
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.icon != null) widget.icon!,
                            if (widget.valueDisplayMode ==
                                    ValueDisplayMode.embedded ||
                                widget.valueDisplayMode ==
                                    ValueDisplayMode.both)
                              Text(
                                formattedText,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                  color: normValue > 0.5
                                      ? activeTheme.textColor
                                      : Colors.white,
                                  fontFamily: activeTheme.fontFamily,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating Bubble HUD
                if (_isDragging &&
                    (widget.valueDisplayMode == ValueDisplayMode.floating ||
                        widget.valueDisplayMode == ValueDisplayMode.both))
                  Positioned(
                    left: isHorizontal
                        ? (fillLength - 24.0).clamp(0.0, width - 48.0)
                        : -60.0,
                    top: isHorizontal
                        ? -44.0
                        : (height - fillLength - 20.0)
                            .clamp(0.0, height - 36.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: activeTheme.bubbleColor,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        formattedText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
