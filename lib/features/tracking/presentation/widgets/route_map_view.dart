import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/models/geo_position.dart';
import 'package:lettuce_travel/features/schools/domain/entities/route_stop.dart';

/// A schematic route diagram: stops in order, connected by the route line,
/// with the bus's live position animated along it.
///
/// This is **not** the Google Maps view called for in AGENTS.md section 2 —
/// `google_maps_flutter` needs platform folders and an API key that do not
/// exist on this machine yet (see the environment note in CLAUDE.md). It
/// exists so the live-tracking screen has something true-to-life to show
/// today; swap the body of [RouteMapView] for a `GoogleMap` once
/// `tool/bootstrap.ps1` has run and `firebase-setup.md`'s API key is in place.
class RouteMapView extends StatelessWidget {
  const RouteMapView({
    required this.stops,
    this.busPosition,
    this.busHeading = 0,
    this.passedStopIds = const <String>{},
    super.key,
  });

  final List<RouteStop> stops;
  final GeoPosition? busPosition;
  final double busHeading;
  final Set<String> passedStopIds;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              color: scheme.surfaceContainerHighest,
              child: CustomPaint(
                painter: _RouteMapPainter(
                  stops: stops,
                  busPosition: busPosition,
                  busHeading: busHeading,
                  passedStopIds: passedStopIds,
                  lineColor: scheme.outlineVariant,
                  passedColor: scheme.outline,
                  upcomingColor: scheme.primary,
                  busColor: scheme.secondary,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          PositionedDirectional(
            top: AppSpacing.sm,
            end: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Text(context.l10n.schematicMapLabel, style: context.text.labelSmall),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  _RouteMapPainter({
    required this.stops,
    required this.busPosition,
    required this.busHeading,
    required this.passedStopIds,
    required this.lineColor,
    required this.passedColor,
    required this.upcomingColor,
    required this.busColor,
  });

  final List<RouteStop> stops;
  final GeoPosition? busPosition;
  final double busHeading;
  final Set<String> passedStopIds;
  final Color lineColor;
  final Color passedColor;
  final Color upcomingColor;
  final Color busColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (stops.isEmpty) return;

    final List<GeoPosition> points = <GeoPosition>[
      for (final RouteStop stop in stops) stop.location,
      if (busPosition != null) busPosition!,
    ];
    double minLat = points.first.lat, maxLat = points.first.lat;
    double minLng = points.first.lng, maxLng = points.first.lng;
    for (final GeoPosition p in points) {
      minLat = math.min(minLat, p.lat);
      maxLat = math.max(maxLat, p.lat);
      minLng = math.min(minLng, p.lng);
      maxLng = math.max(maxLng, p.lng);
    }
    final double latSpan = (maxLat - minLat).abs() < 0.0005 ? 0.01 : (maxLat - minLat);
    final double lngSpan = (maxLng - minLng).abs() < 0.0005 ? 0.01 : (maxLng - minLng);

    const double padding = 28;
    Offset project(GeoPosition p) {
      final double x = padding + (p.lng - minLng) / lngSpan * (size.width - padding * 2);
      // Latitude increases upward geographically, but canvas y grows downward.
      final double y =
          padding + (1 - (p.lat - minLat) / latSpan) * (size.height - padding * 2);
      return Offset(x, y);
    }

    final List<Offset> stopOffsets = <Offset>[for (final RouteStop s in stops) project(s.location)];

    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < stopOffsets.length - 1; i++) {
      canvas.drawLine(stopOffsets[i], stopOffsets[i + 1], linePaint);
    }

    for (int i = 0; i < stops.length; i++) {
      final bool passed = passedStopIds.contains(stops[i].id);
      final Paint dotPaint = Paint()..color = passed ? passedColor : upcomingColor;
      canvas.drawCircle(stopOffsets[i], 7, dotPaint);
      canvas.drawCircle(
        stopOffsets[i],
        7,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final TextPainter labelPainter = TextPainter(
        text: TextSpan(
          text: '${stops[i].order}',
          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        stopOffsets[i] - Offset(labelPainter.width / 2, labelPainter.height / 2),
      );
    }

    if (busPosition != null) {
      final Offset busOffset = project(busPosition!);
      canvas.save();
      canvas.translate(busOffset.dx, busOffset.dy);
      canvas.rotate(busHeading * math.pi / 180);
      final Path bus = Path()
        ..moveTo(0, -12)
        ..lineTo(9, 10)
        ..lineTo(0, 5)
        ..lineTo(-9, 10)
        ..close();
      canvas.drawPath(bus, Paint()..color = busColor);
      canvas.drawPath(
        bus,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter oldDelegate) =>
      oldDelegate.busPosition != busPosition ||
      oldDelegate.busHeading != busHeading ||
      oldDelegate.passedStopIds.length != passedStopIds.length;
}
