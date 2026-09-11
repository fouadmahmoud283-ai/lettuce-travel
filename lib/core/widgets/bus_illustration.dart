import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An original, hand-painted school-bus scene — no photo or icon-font
/// dependency, so it costs nothing at runtime and carries no licensing risk.
///
/// Used on the welcome screen and, smaller, echoed on the splash screen for
/// brand continuity. Purely decorative: [CustomPainter.shouldRepaint] is
/// always false since nothing here is ever animated or data-driven.
class BusIllustration extends StatelessWidget {
  const BusIllustration({
    this.height = 220,
    this.onDark = true,
    super.key,
  });

  final double height;

  /// True when painted over a dark gradient (the welcome/splash screens);
  /// flips a couple of accent colours for contrast when false.
  final bool onDark;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _BusScenePainter(onDark: onDark),
        ),
      );
}

class _BusScenePainter extends CustomPainter {
  _BusScenePainter({required this.onDark});

  final bool onDark;

  // Palette kept local to the painter rather than pulled from AppColors:
  // this illustration is a fixed piece of art, not a themed component, so it
  // should look the same regardless of where AppColors' brand tones move.
  static const Color _busBody = Color(0xFFF2A65A);
  static const Color _busBodyDark = Color(0xFFD98A3D);
  static const Color _busRoof = Color(0xFFFFC47A);
  static const Color _window = Color(0xFFEAF6FF);
  static const Color _windowFrame = Color(0xFF0B4543);
  static const Color _wheel = Color(0xFF1F2A2A);
  static const Color _hubcap = Color(0xFFD8DEDE);
  static const Color _road = Color(0xFF14201F);
  static const Color _roadLine = Color(0xFFF7FAF5);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    _paintSky(canvas, w, h);
    _paintRoad(canvas, w, h);
    _paintBus(canvas, w, h);
  }

  void _paintSky(Canvas canvas, double w, double h) {
    // Sun / glow, upper-right — a soft radial disc, never a hard edge.
    final Offset sunCenter = Offset(w * 0.82, h * 0.18);
    final Paint glow = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          Colors.white.withValues(alpha: onDark ? 0.35 : 0.55),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.22));
    canvas.drawCircle(sunCenter, w * 0.22, glow);
    canvas.drawCircle(
      sunCenter,
      w * 0.05,
      Paint()..color = Colors.white.withValues(alpha: onDark ? 0.9 : 0.85),
    );

    // Two simple cloud puffs, upper-left, drawn as three overlapping circles.
    _paintCloud(canvas, Offset(w * 0.16, h * 0.2), w * 0.05);
    _paintCloud(canvas, Offset(w * 0.30, h * 0.12), w * 0.035);
  }

  void _paintCloud(Canvas canvas, Offset center, double r) {
    final Paint cloud = Paint()..color = Colors.white.withValues(alpha: onDark ? 0.22 : 0.65);
    canvas.drawCircle(center + Offset(-r * 0.9, 0), r * 0.8, cloud);
    canvas.drawCircle(center, r, cloud);
    canvas.drawCircle(center + Offset(r * 0.9, 0), r * 0.7, cloud);
  }

  void _paintRoad(Canvas canvas, double w, double h) {
    final double roadTop = h * 0.82;
    canvas.drawRect(Rect.fromLTRB(0, roadTop, w, h), Paint()..color = _road);

    final Paint dash = Paint()
      ..color = _roadLine.withValues(alpha: 0.85)
      ..strokeWidth = h * 0.014
      ..strokeCap = StrokeCap.round;
    final double lineY = roadTop + (h - roadTop) / 2;
    const double dashWidth = 18;
    const double gapWidth = 14;
    double x = -((dashWidth + gapWidth) / 2); // stagger so it feels in-motion
    while (x < w) {
      canvas.drawLine(Offset(x, lineY), Offset(x + dashWidth, lineY), dash);
      x += dashWidth + gapWidth;
    }
  }

  void _paintBus(Canvas canvas, double w, double h) {
    final double roadTop = h * 0.82;
    final double busWidth = w * 0.62;
    final double busHeight = h * 0.42;
    final double busLeft = (w - busWidth) / 2;
    final double busTop = roadTop - busHeight + h * 0.04;

    final Rect body = Rect.fromLTWH(busLeft, busTop, busWidth, busHeight);
    final RRect busRRect = RRect.fromRectAndCorners(
      body,
      topLeft: Radius.circular(busHeight * 0.28),
      topRight: Radius.circular(busHeight * 0.5),
      bottomLeft: Radius.circular(busHeight * 0.12),
      bottomRight: Radius.circular(busHeight * 0.12),
    );

    // Soft contact shadow under the bus.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(busLeft + busWidth / 2, roadTop + h * 0.02),
        width: busWidth * 1.05,
        height: h * 0.05,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );

    // Body: a subtle vertical gradient reads as painted metal rather than flat.
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[_busRoof, _busBody, _busBodyDark],
        stops: const <double>[0, 0.55, 1],
      ).createShader(body);
    canvas.drawRRect(busRRect, bodyPaint);

    // Roof accent stripe.
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(busLeft, busTop, busWidth, busHeight * 0.16),
        topLeft: Radius.circular(busHeight * 0.28),
        topRight: Radius.circular(busHeight * 0.5),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    // Windows: four evenly spaced rounded rectangles along the upper body.
    final double windowTop = busTop + busHeight * 0.30;
    final double windowHeight = busHeight * 0.30;
    const int windowCount = 4;
    final double windowsAreaLeft = busLeft + busWidth * 0.08;
    final double windowsAreaRight = busLeft + busWidth * 0.92;
    final double totalWindowSpan = windowsAreaRight - windowsAreaLeft;
    final double gap = totalWindowSpan * 0.06;
    final double windowWidth = (totalWindowSpan - gap * (windowCount - 1)) / windowCount;
    for (int i = 0; i < windowCount; i++) {
      final double left = windowsAreaLeft + i * (windowWidth + gap);
      final RRect win = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, windowTop, windowWidth, windowHeight),
        Radius.circular(windowWidth * 0.22),
      );
      canvas.drawRRect(win, Paint()..color = _window);
      canvas.drawRRect(
        win,
        Paint()
          ..color = _windowFrame.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      // A soft glare triangle on each pane.
      final Path glare = Path()
        ..moveTo(left + windowWidth * 0.12, windowTop + windowHeight * 0.85)
        ..lineTo(left + windowWidth * 0.12, windowTop + windowHeight * 0.25)
        ..lineTo(left + windowWidth * 0.55, windowTop + windowHeight * 0.85)
        ..close();
      canvas.drawPath(glare, Paint()..color = Colors.white.withValues(alpha: 0.55));
    }

    // Lower body accent band, just above the wheel line.
    canvas.drawRect(
      Rect.fromLTWH(busLeft, busTop + busHeight * 0.72, busWidth, busHeight * 0.08),
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );

    // Headlight, front (right) edge.
    canvas.drawCircle(
      Offset(busLeft + busWidth * 0.965, busTop + busHeight * 0.62),
      busHeight * 0.06,
      Paint()..color = const Color(0xFFFFF3C4),
    );

    // Wheels.
    final double wheelRadius = busHeight * 0.19;
    final double wheelY = busTop + busHeight - wheelRadius * 0.55;
    _paintWheel(canvas, Offset(busLeft + busWidth * 0.22, wheelY), wheelRadius);
    _paintWheel(canvas, Offset(busLeft + busWidth * 0.78, wheelY), wheelRadius);
  }

  void _paintWheel(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = _wheel);
    canvas.drawCircle(center, radius * 0.52, Paint()..color = _hubcap);
    canvas.drawCircle(
      center,
      radius * 0.16,
      Paint()..color = _wheel.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _BusScenePainter oldDelegate) => oldDelegate.onDark != onDark;
}

/// A small inline glyph — three overlapping avatar-style circles — used
/// wherever the UI wants to say "families, supervisors and staff" in one
/// compact graphic rather than three separate icons (e.g. the welcome
/// screen's role strip).
class RoleTrioBadge extends StatelessWidget {
  const RoleTrioBadge({this.size = 40, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: size,
        width: size * 2.1,
        child: Stack(
          children: <Widget>[
            _dot(0, const Color(0xFFE76F51)),
            _dot(size * 0.55, const Color(0xFFF2A65A)),
            _dot(size * 1.1, const Color(0xFF20C7BB)),
          ],
        ),
      );

  Widget _dot(double left, Color color) => Positioned(
        left: left,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 2.5),
          ),
        ),
      );
}

/// Decorative blurred colour blobs used behind auth-screen content to break
/// up an otherwise flat surface. Pure geometry, no assets.
class DecorativeBlobs extends StatelessWidget {
  const DecorativeBlobs({required this.colors, super.key});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomPaint(
          painter: _BlobsPainter(colors: colors),
          child: const SizedBox.expand(),
        ),
      );
}

class _BlobsPainter extends CustomPainter {
  _BlobsPainter({required this.colors});

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    void blob(Offset center, double radius, Color color) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    blob(Offset(size.width * 0.1, size.height * 0.05), size.width * 0.6, colors[0]);
    blob(
      Offset(size.width * 0.95, size.height * 0.25),
      size.width * 0.5,
      colors[math.min(1, colors.length - 1)],
    );
  }

  @override
  bool shouldRepaint(covariant _BlobsPainter oldDelegate) => false;
}
