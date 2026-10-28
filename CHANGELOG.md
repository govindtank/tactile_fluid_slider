## 1.1.0

- **Dual-Layer Inverted Text Masking**: Replaced naive 50% color flip with a pixel-perfect `ClipRRect` inverted mask so embedded labels and icons maintain maximum contrast regardless of screen width or fill fraction.
- **Tap-to-Seek**: Tapping anywhere on the slider track animates smoothly to that value with spring physics.
- **Double-Tap Reset**: Snaps back to `defaultValue` with haptic feedback on double-tap.
- **Fine-Scrubbing Mode**: Dragging finger perpendicular to slider track slows down sensitivity to 0.35x for ultra-precise micro-adjustments with HUD indicator.
- **Dynamic Track Expansion**: Track expands slightly during active touch down for superior tactile feedback.

## 1.0.0

- Initial release of `tactile_fluid_slider`.
- **Elastic Rubber-Band Squash Physics**: Boundary overscroll resistance with smooth spring release recoil.
- **Stepped Haptic Detents**: Tactile haptic feedback ticks when crossing snap threshold intervals.
- **Embedded & Floating Value Bubbles**: Displays dynamic numerical feedback either centered inside the pill or floating above the contact thumb.
- **Horizontal & Vertical Orientations**: Full support for volume/brightness bars and Control Center vertical faders.
- **Smooth Theming**: Customizable track and active colors, border radiuses, and glass gradients.
- **Multi-Platform Ready**: 100% pure Dart & Flutter implementation.
