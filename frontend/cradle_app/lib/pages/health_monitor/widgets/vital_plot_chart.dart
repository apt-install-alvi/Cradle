import 'package:flutter/material.dart';
import '../../../core/widgets/bottom_nav.dart';

/// Simple 7-day line + filled-area chart matching the HTML prototype's
/// buildPlotGraph(). Last point is drawn solid; earlier points are hollow.
class VitalPlotChart extends StatelessWidget {
  const VitalPlotChart({super.key, required this.values, this.height = 76});

  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _VitalPlotPainter(values: values),
      ),
    );
  }
}

class _VitalPlotPainter extends CustomPainter {
  _VitalPlotPainter({required this.values});

  final List<double> values;
  static const Color brand = DashboardBottomNav.primaryPink;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const padX = 10.0;
    const padY = 12.0;
    final w = size.width;
    final h = size.height;

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
    final n = values.length;
    final stepX = n > 1 ? (w - padX * 2) / (n - 1) : 0.0;

    final points = <Offset>[];
    for (int i = 0; i < n; i++) {
      final x = padX + stepX * i;
      final y = (n == 1 || maxV == minV)
          ? h / 2
          : (h - padY) - ((values[i] - minV) / span) * (h - padY * 2);
      points.add(Offset(x, y));
    }

    // Filled area under the line.
    final areaPath = Path()..moveTo(padX, h);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(points.last.dx, h);
    areaPath.close();
    canvas.drawPath(
      areaPath,
      Paint()..color = brand.withValues(alpha: 0.08),
    );

    // Line.
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = brand
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Points — last one solid, others hollow.
    for (int i = 0; i < points.length; i++) {
      final isLast = i == points.length - 1;
      final p = points[i];
      canvas.drawCircle(
        p,
        isLast ? 4 : 3,
        Paint()..color = isLast ? brand : Colors.white,
      );
      canvas.drawCircle(
        p,
        isLast ? 4 : 3,
        Paint()
          ..color = brand
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VitalPlotPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
