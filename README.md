# tactile_fluid_slider

<p align="center">
  <a href="https://pub.dev/packages/tactile_fluid_slider"><img src="https://img.shields.io/pub/v/tactile_fluid_slider.svg?style=flat-square&color=blue" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/tactile_fluid_slider/score"><img src="https://img.shields.io/pub/points/tactile_fluid_slider?style=flat-square&color=2E8B57&label=pub%20points" alt="Pub Points"></a>
  <a href="https://govindtank.github.io/tactile_fluid_slider/"><img src="https://img.shields.io/badge/Live%20Demo-Try%20In%20Browser-00ff88?style=flat-square&logo=flutter" alt="Live Demo"></a>
  <a href="https://pub.dev/packages/tactile_fluid_slider"><img src="https://img.shields.io/pub/likes/tactile_fluid_slider?style=flat-square" alt="Pub Likes"></a>
  <a href="https://github.com/govindtank/tactile_fluid_slider/actions"><img src="https://github.com/govindtank/tactile_fluid_slider/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square" alt="License"></a>
</p>

A modern tactile fluid slider for Flutter inspired by iOS 18 Control Center and Apple Home. Features **elastic rubber-band boundary squash physics, stepped haptic detents, and floating value HUD bubbles**.

---

## ⚡ Why `tactile_fluid_slider`?

Flutter's built-in `Slider` is rigid and dates back to Material 2 guidelines. Modern mobile operating systems (iOS 18, Nothing OS, Apple Home) have evolved to thick, tactile fluid capsules where the thumb and track feel alive:

* 🧽 **Rubber-Band Squash & Stretch**: Dragging past 0% or 100% applies exponential resistance — the pill visibly squashes and stretches, snapping back with spring physics on release.
* 📳 **Magnetic Haptic Detents**: Fires subtle tactile clicks (`HapticFeedback.selectionClick()`) when crossing key thresholds (e.g., 25%, 50%, 75%, 100%).
* 💬 **Floating Value Bubble HUD**: The numerical indicator floats above the finger on touch-down and animates smoothly along the track.
* ↕️ **Horizontal & Vertical Support**: Seamlessly switch between media volume horizontal bars and Control Center vertical faders.

---

## 🚀 Features

| Feature | Description |
|---|---|
| **🧽 Boundary Rubber-Band Physics** | Dynamic squash and stretch animation when dragged past minimum or maximum bounds. |
| **📳 Tactile Haptic Detents** | Configurable magnetic thresholds that trigger subtle haptic clicks. |
| **💬 Floating & Embedded Value HUD** | Supports `embedded` labels inside the track, `floating` tooltip bubbles above the contact thumb, or `both`. |
| **↕️ Multi-Orientation** | Supports both `Axis.horizontal` (brightness/sound bars) and `Axis.vertical` (studio lighting faders). |
| **🎨 3 Design Presets** | `dark()` (Obsidian slate), `light()`, and `appleHome()` (amber glow). |
| **🌐 Multi-Platform** | 100% pure Dart & Flutter with zero native dependencies. Works on iOS, Android, Web, macOS, Windows, and Linux. |

---

## 📦 Installation

Add `tactile_fluid_slider` to your `pubspec.yaml`:

```bash
flutter pub add tactile_fluid_slider
```

---

## 💡 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:tactile_fluid_slider/tactile_fluid_slider.dart';

class MySliderScreen extends StatefulWidget {
  const MySliderScreen({super.key});

  @override
  State<MySliderScreen> createState() => _MySliderScreenState();
}

class _MySliderScreenState extends State<MySliderScreen> {
  double _brightness = 0.70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Center(
        child: SizedBox(
          width: 280,
          child: TactileFluidSlider(
            value: _brightness,
            onChanged: (val) => setState(() => _brightness = val),
            icon: const Icon(Icons.wb_sunny_rounded, size: 20),
            valueDisplayMode: ValueDisplayMode.floating,
            theme: TactileSliderTheme.dark(),
          ),
        ),
      ),
    );
  }
}
```

---

## ↕️ Vertical Fader

```dart
SizedBox(
  height: 180,
  width: 60,
  child: TactileFluidSlider(
    value: _volume,
    orientation: Axis.vertical,
    onChanged: (val) => setState(() => _volume = val),
    icon: const Icon(Icons.volume_up_rounded),
  ),
)
```

---

## 🔗 Related Packages by Author

* **[smooth_signature_pad](https://pub.dev/packages/smooth_signature_pad)** — Fountain pen velocity pressure simulation and vector SVG export.
* **[flutter_privacy_vault](https://pub.dev/packages/flutter_privacy_vault)** — App-switcher privacy shield, inactivity auto-lock, and balance masking.
* **[ai_stream_bubble](https://pub.dev/packages/ai_stream_bubble)** — High-performance streaming AI message bubble with DeepSeek/Claude reasoning accordions.
* **[flutter_sonner](https://pub.dev/packages/flutter_sonner)** — Opinionated stacked action toast & notification HUD.

---

## 💖 Support the Project

If you find this project useful, consider supporting its active maintenance and future development:

<p align="left">
  <a href="https://buymeacoffee.com/govindtanko"><img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee" /></a>
  <a href="https://github.com/sponsors/govindtank"><img src="https://img.shields.io/badge/GitHub%20Sponsors-EA4AAA?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Sponsors" /></a>
  <a href="https://www.patreon.com/govindtank"><img src="https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white" alt="Patreon" /></a>
</p>

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

*Maintained with ❤️ by [Govind Tank](https://github.com/govindtank).*
