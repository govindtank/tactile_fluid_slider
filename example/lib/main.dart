import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tactile_fluid_slider/tactile_fluid_slider.dart';

void main() {
  runApp(const TactileSliderDemoApp());
}

class TactileSliderDemoApp extends StatefulWidget {
  const TactileSliderDemoApp({super.key});

  @override
  State<TactileSliderDemoApp> createState() => _TactileSliderDemoAppState();
}

enum DemoThemeMode { dark, light, appleHome }

class _TactileSliderDemoAppState extends State<TactileSliderDemoApp> {
  DemoThemeMode _themeMode = DemoThemeMode.dark;

  TactileSliderTheme get _sliderTheme {
    switch (_themeMode) {
      case DemoThemeMode.dark:
        return TactileSliderTheme.dark();
      case DemoThemeMode.light:
        return TactileSliderTheme.light();
      case DemoThemeMode.appleHome:
        return TactileSliderTheme.appleHome();
    }
  }

  Color get _scaffoldColor {
    switch (_themeMode) {
      case DemoThemeMode.dark:
        return const Color(0xFF09090B);
      case DemoThemeMode.light:
        return const Color(0xFFF4F4F5);
      case DemoThemeMode.appleHome:
        return const Color(0xFF0C0A09);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tactile_fluid_slider — Interactive Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _themeMode == DemoThemeMode.light
            ? Brightness.light
            : Brightness.dark,
        scaffoldBackgroundColor: _scaffoldColor,
        useMaterial3: true,
      ),
      home: ControlCenterScreen(
        sliderTheme: _sliderTheme,
        themeMode: _themeMode,
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

class ControlCenterScreen extends StatefulWidget {
  const ControlCenterScreen({
    super.key,
    required this.sliderTheme,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final TactileSliderTheme sliderTheme;
  final DemoThemeMode themeMode;
  final ValueChanged<DemoThemeMode> onThemeChanged;

  @override
  State<ControlCenterScreen> createState() => _ControlCenterScreenState();
}

class _ControlCenterScreenState extends State<ControlCenterScreen> {
  double _brightness = 0.65;
  double _volume = 0.40;
  double _studioLight = 0.85;
  bool _copiedCommand = false;

  Future<void> _copyPubCommand() async {
    await Clipboard.setData(
      const ClipboardData(text: 'flutter pub add tactile_fluid_slider'),
    );
    HapticFeedback.lightImpact();
    setState(() => _copiedCommand = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedCommand = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, color: Color(0xFFF59E0B), size: 20),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'tactile_fluid_slider',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // 1-Tap Copy Install Button
          InkWell(
            onTap: _copyPubCommand,
            borderRadius: BorderRadius.circular(6.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: _copiedCommand
                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: _copiedCommand
                      ? const Color(0xFF10B981)
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _copiedCommand ? Icons.check : Icons.terminal_rounded,
                    size: 14,
                    color: _copiedCommand
                        ? const Color(0xFF10B981)
                        : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _copiedCommand ? 'Copied pub add!' : 'pub add',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _copiedCommand
                          ? const Color(0xFF10B981)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<DemoThemeMode>(
              value: widget.themeMode,
              icon: const Icon(Icons.palette_outlined, size: 18),
              onChanged: (mode) {
                if (mode != null) widget.onThemeChanged(mode);
              },
              items: const [
                DropdownMenuItem(
                  value: DemoThemeMode.dark,
                  child: Text('Dark Slate'),
                ),
                DropdownMenuItem(
                  value: DemoThemeMode.light,
                  child: Text('Light Clean'),
                ),
                DropdownMenuItem(
                  value: DemoThemeMode.appleHome,
                  child: Text('Apple Home'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'iOS 18 Control Center & Home Faders',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6.0),
                const Text(
                  'Drag beyond edges to experience elastic rubber-band squash physics with magnetic haptic detents.',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
                const SizedBox(height: 28.0),

                // Horizontal Brightness Slider
                const Text(
                  'DISPLAY BRIGHTNESS (FLOATING HUD)',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10.0),
                TactileFluidSlider(
                  value: _brightness,
                  onChanged: (val) => setState(() => _brightness = val),
                  icon: const Icon(Icons.wb_sunny_rounded, size: 22),
                  valueDisplayMode: ValueDisplayMode.both,
                  valueFormatter: (v) => '${(v * 100).round()}% Brightness',
                  theme: widget.sliderTheme,
                ),
                const SizedBox(height: 24.0),

                // Horizontal Volume Slider
                const Text(
                  'MEDIA VOLUME (EMBEDDED LABEL)',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10.0),
                TactileFluidSlider(
                  value: _volume,
                  onChanged: (val) => setState(() => _volume = val),
                  icon: Icon(
                    _volume > 0.5
                        ? Icons.volume_up_rounded
                        : (_volume > 0
                            ? Icons.volume_down_rounded
                            : Icons.volume_mute_rounded),
                    size: 22,
                  ),
                  valueDisplayMode: ValueDisplayMode.embedded,
                  valueFormatter: (v) => '${(v * 100).round()} dB',
                  theme: widget.sliderTheme,
                ),
                const SizedBox(height: 28.0),

                // Vertical Fader Section
                const Text(
                  'VERTICAL STUDIO LIGHT FADER',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 180,
                        width: 60,
                        child: TactileFluidSlider(
                          value: _studioLight,
                          orientation: Axis.vertical,
                          onChanged: (val) =>
                              setState(() => _studioLight = val),
                          icon: const Icon(Icons.lightbulb_rounded, size: 22),
                          valueDisplayMode: ValueDisplayMode.floating,
                          theme: widget.sliderTheme,
                        ),
                      ),
                      const SizedBox(width: 24.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Key Light Intensity',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              'Current value: ${(_studioLight * 100).round()}%\n'
                              'Features vertical drag with rubber-band physics on top and bottom boundaries.',
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
