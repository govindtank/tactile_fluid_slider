import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/slider_config.dart';

/// A modern, tactile thick fluid slider with dual-layer inverted text masking,
/// boundary rubber-band squash physics, stepped haptic detents, tap-to-seek,
/// and fine-scrubbing sensitivity.
class TactileFluidSlider extends StatefulWidget {
  const TactileFluidSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.defaultValue,
    this.orientation = Axis.horizontal,
    this.valueDisplayMode = ValueDisplayMode.embedded,
    this.valueFormatter,
    this.hapticDetents = const [0.25, 0.5, 0.75, 1.0],
    this.icon,
    this.theme,
    this.enableHaptics = true,
    this.enableTapToSeek = true,
    this.enableDoubleTapReset = true,
    this.enableFineScrubbing = true,
  })  : assert(min <= max, 'min must be less than or equal to max'),
        assert(
            value >= min && value <= max, 'value must be between min and max');

  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final double? defaultValue;
  final Axis orientation;
  final ValueDisplayMode valueDisplayMode;
  final String Function(double value)? valueFormatter;
  final List<double>? hapticDetents;
  final Widget? icon;
  final TactileSliderTheme? theme;
  final bool enableHaptics;
  final bool enableTapToSeek;
  final bool enableDoubleTapReset;
  final bool enableFineScrubbing;

  @override
  State<TactileFluidSlider> createState() => _TactileFluidSliderState();
}

class _TactileFluidSliderState extends State<TactileFluidSlider>
    with TickerProviderStateMixin {
  late AnimationController _recoilController;
  late Animation<double> _recoilAnimation;

  late AnimationController _seekController;
  late Animation<double> _seekAnimation;

  double _overscroll = 0.0;
  bool _isDragging = false;
  bool _isFineScrubbing = false;
  double _lastDetentCrossed = -1.0;
  Offset _dragStartPos = Offset.zero;
  double _dragStartValue = 0.0;

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

    _seekController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _recoilController.dispose();
    _seekController.dispose();
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
    _seekController.stop();
    setState(() {
      _isDragging = true;
      _isFineScrubbing = false;
      _dragStartPos = localPos;
      _dragStartValue = widget.value;
    });
    widget.onChangeStart?.call(widget.value);
    _handleDragUpdate(localPos, size);
  }

  void _handleDragUpdate(Offset localPos, Size size) {
    final isHorizontal = widget.orientation == Axis.horizontal;
    final totalLength = isHorizontal ? size.width : size.height;

    // Check perpendicular drag distance for fine scrubbing mode
    if (widget.enableFineScrubbing) {
      final perpDistance = isHorizontal
          ? (localPos.dy - _dragStartPos.dy).abs()
          : (localPos.dx - _dragStartPos.dx).abs();

      final fine = perpDistance > 45.0;
      if (fine != _isFineScrubbing) {
        setState(() => _isFineScrubbing = fine);
        if (widget.enableHaptics) HapticFeedback.lightImpact();
      }
    }

    final currentPos = isHorizontal ? localPos.dx : (size.height - localPos.dy);
    double fraction;

    if (_isFineScrubbing) {
      // Fine-scrubbing applies 0.35x speed delta from start position
      final deltaPos = isHorizontal
          ? (localPos.dx - _dragStartPos.dx)
          : (_dragStartPos.dy - localPos.dy);
      final fineDeltaFraction = (deltaPos / totalLength) * 0.35;
      final startFraction =
          (_dragStartValue - widget.min) / (widget.max - widget.min);
      fraction = (startFraction + fineDeltaFraction).clamp(0.0, 1.0);
      _overscroll = 0.0;
    } else {
      fraction = currentPos / totalLength;

      if (fraction < 0.0) {
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
    }

    final newValue = widget.min + fraction * (widget.max - widget.min);
    final clamped = newValue.clamp(widget.min, widget.max);

    _triggerHapticIfCrossed(fraction);

    if (clamped != widget.value) {
      widget.onChanged(clamped);
    }
  }

  void _handleDragEnd() {
    setState(() {
      _isDragging = false;
      _isFineScrubbing = false;
    });
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

  void _handleTapToSeek(Offset localPos, Size size) {
    if (!widget.enableTapToSeek || _isDragging) return;

    final isHorizontal = widget.orientation == Axis.horizontal;
    final totalLength = isHorizontal ? size.width : size.height;
    final targetPos = isHorizontal ? localPos.dx : (size.height - localPos.dy);
    final fraction = (targetPos / totalLength).clamp(0.0, 1.0);
    final targetValue = widget.min + fraction * (widget.max - widget.min);

    final startVal = widget.value;
    _seekAnimation = Tween<double>(begin: startVal, end: targetValue).animate(
      CurvedAnimation(parent: _seekController, curve: Curves.easeOutCubic),
    )..addListener(() {
        widget.onChanged(_seekAnimation.value);
      });

    if (widget.enableHaptics) HapticFeedback.selectionClick();
    _seekController.forward(from: 0.0);
  }

  void _handleDoubleTapReset() {
    if (!widget.enableDoubleTapReset) return;
    final resetVal = widget.defaultValue ?? widget.min;

    final startVal = widget.value;
    _seekAnimation = Tween<double>(begin: startVal, end: resetVal).animate(
      CurvedAnimation(parent: _seekController, curve: Curves.easeOutBack),
    )..addListener(() {
        widget.onChanged(_seekAnimation.value);
      });

    if (widget.enableHaptics) HapticFeedback.mediumImpact();
    _seekController.forward(from: 0.0);
  }

  String _formatValue(double val) {
    if (widget.valueFormatter != null) {
      return widget.valueFormatter!(val);
    }
    final percentage =
        ((val - widget.min) / (widget.max - widget.min) * 100).round();
    return '$percentage%';
  }

  Widget _buildContentLayer({
    required Color textColor,
    required Color iconColor,
    required String text,
    required String? fontFamily,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.icon != null)
            IconTheme(
              data: IconThemeData(color: iconColor, size: 22.0),
              child: widget.icon!,
            ),
          if (widget.valueDisplayMode == ValueDisplayMode.embedded ||
              widget.valueDisplayMode == ValueDisplayMode.both)
            Text(
              text,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                color: textColor,
                fontFamily: fontFamily,
              ),
            ),
        ],
      ),
    );
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
        final baseWidth =
            isHorizontal ? constraints.maxWidth : activeTheme.trackWidth;
        final baseHeight =
            isHorizontal ? activeTheme.trackHeight : constraints.maxHeight;

        // Subtle track expansion on active dragging
        final expandDelta =
            (_isDragging && activeTheme.expandOnDrag) ? 4.0 : 0.0;
        final width = isHorizontal ? baseWidth : (baseWidth + expandDelta);
        final height = isHorizontal ? (baseHeight + expandDelta) : baseHeight;

        final fillLength = (isHorizontal ? width : height) * normValue;

        return GestureDetector(
          onTapDown: (d) =>
              _handleTapToSeek(d.localPosition, Size(width, height)),
          onTapUp: (d) =>
              _handleTapToSeek(d.localPosition, Size(width, height)),
          onDoubleTap: _handleDoubleTapReset,
          onHorizontalDragStart: isHorizontal
              ? (d) => _handleDragStart(d.localPosition, Size(width, height))
              : null,
          onHorizontalDragUpdate: isHorizontal
              ? (d) => _handleDragUpdate(d.localPosition, Size(width, height))
              : null,
          onHorizontalDragEnd: isHorizontal ? (_) => _handleDragEnd() : null,
          onHorizontalDragCancel: isHorizontal ? () => _handleDragEnd() : null,
          onVerticalDragStart: !isHorizontal
              ? (d) => _handleDragStart(d.localPosition, Size(width, height))
              : null,
          onVerticalDragUpdate: !isHorizontal
              ? (d) => _handleDragUpdate(d.localPosition, Size(width, height))
              : null,
          onVerticalDragEnd: !isHorizontal ? (_) => _handleDragEnd() : null,
          onVerticalDragCancel: !isHorizontal ? () => _handleDragEnd() : null,
          child: Transform.scale(
            scaleX: isHorizontal ? stretchScale : squashScale,
            scaleY: isHorizontal ? squashScale : stretchScale,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Base Track Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
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
                    children: [
                      // Layer A: Unfilled Content (resting on background track)
                      SizedBox(
                        width: width,
                        height: height,
                        child: _buildContentLayer(
                          textColor: activeTheme.effectiveUnfilledTextColor,
                          iconColor: activeTheme.effectiveUnfilledTextColor,
                          text: formattedText,
                          fontFamily: activeTheme.fontFamily,
                        ),
                      ),

                      // Layer B: Filled Active Bar with Inverted Text Mask
                      Align(
                        alignment: isHorizontal
                            ? Alignment.centerLeft
                            : Alignment.bottomCenter,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(activeTheme.borderRadius),
                          child: SizedBox(
                            width: isHorizontal ? fillLength : width,
                            height: isHorizontal ? height : fillLength,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Fill Color / Gradient
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: activeTheme.activeGradient == null
                                          ? activeTheme.activeColor
                                          : null,
                                      gradient: activeTheme.activeGradient,
                                    ),
                                  ),
                                ),
                                // Inverted Mask Content positioned at track origin
                                Positioned(
                                  left: 0,
                                  bottom: 0,
                                  width: width,
                                  height: height,
                                  child: _buildContentLayer(
                                    textColor:
                                        activeTheme.effectiveFilledTextColor,
                                    iconColor:
                                        activeTheme.effectiveFilledTextColor,
                                    text: formattedText,
                                    fontFamily: activeTheme.fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Floating Bubble HUD
                if (_isDragging &&
                    (widget.valueDisplayMode == ValueDisplayMode.floating ||
                        widget.valueDisplayMode == ValueDisplayMode.both))
                  Positioned(
                    left: isHorizontal
                        ? (fillLength - 36.0).clamp(0.0, width - 72.0)
                        : -85.0,
                    top: isHorizontal
                        ? -48.0
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
                        border: _isFineScrubbing
                            ? Border.all(
                                color: const Color(0xFF38BDF8), width: 1.2)
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isFineScrubbing) ...[
                            const Icon(Icons.precision_manufacturing_rounded,
                                size: 12, color: Color(0xFF38BDF8)),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            _isFineScrubbing
                                ? 'Fine: $formattedText'
                                : formattedText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
