import 'dart:math';

import 'package:flutter/material.dart';

/// [ScrollIndicator] widget to show custom scroll indicator
class ScrollIndicator extends StatelessWidget {
  const ScrollIndicator({
    Key? key,
    required this.height,
    required this.width,
    required this.offsetPercent,
    this.color = Colors.white,
    this.diamondColor = Colors.white,
  }) : super(key: key);

  final double height;
  final double width;
  final double offsetPercent;
  final Color color;
  final Color diamondColor;

  /// Capsule widths
  double get _capsule1Width => width * 0.75;
  double get _capsule2Width => width * 0.50;
  double get _capsule3Width => width * 0.25;

  /// Capsule left positions
  double get _capsule1Left {
    double view100Percent = width - _capsule1Width;
    return _offsetPercent * view100Percent / 100;
  }

  double get _capsule2Left {
    double view100Percent = width - _capsule2Width;
    return _offsetPercent * view100Percent / 100;
  }

  double get _capsule3Left {
    double view100Percent = width - _capsule3Width;
    return _offsetPercent * view100Percent / 100;
  }

  /// Diamond widget left position
  double get _diamondLeft =>
      _capsule3Left + (_capsule3Width / 2.0) - (height / 2.0);

  /// Diamond widget degree to rotate based on current [_offsetPercent]
  double get _diamondDegree => _offsetPercent * 360.0 / 100.0;

  /// Calculates current [_offsetPercent] based on [offsetPercent] of [ScrollController]
  double get _offsetPercent {
    // print(offsetPercent);
    if (offsetPercent < -8.0) {
      return -8.0;
    } else if (offsetPercent > 108.0) {
      return 108.0;
    }
    return offsetPercent;
  }

  /// Gradient colors for outer capsule shape
  List<Color> get _gradientColors {
    return [
      color.withAlpha(
        max(255 - (255 * _offsetPercent / 100).round(), (255 * 0.3).round()),
      ),
      color,
      color.withAlpha(
        max((255 * _offsetPercent / 100).round(), (255 * 0.3).round()),
      ),
    ];
  }

  /// [stops] for gradient of outer capsule shape
  List<double> get _gradientStops => [0, _offsetPercent / 100, 1];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        // To clip any sub widget showing out of it's bounds on overscroll
        borderRadius: BorderRadius.circular(height / 2),
        child: CustomPaint(
          painter: _GradientPainter(
            strokeWidth: 1,
            radius: height / 2,
            gradient: LinearGradient(
              colors: _gradientColors,
              stops: _gradientStops,
            ),
          ),
          child: Stack(
            children: [
              _CapsuleView(
                  left: _capsule1Left,
                  height: height,
                  width: _capsule1Width,
                  color: color.withAlpha(76)),
              _CapsuleView(
                  left: _capsule2Left,
                  height: height,
                  width: _capsule2Width,
                  color: color.withAlpha(76)),
              _CapsuleView(
                  left: _capsule3Left,
                  height: height,
                  width: _capsule3Width,
                  color: color.withAlpha(76)),
              _DiamondView(
                size: height,
                left: _diamondLeft,
                degree: _diamondDegree,
                color: diamondColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [CustomPainter] to draw border with gradient
/// ref: https://stackoverflow.com/a/55638138/1223897
class _GradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  _GradientPainter(
      {required this.strokeWidth,
      required this.radius,
      required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    Rect outerRect = Offset.zero & size;
    var outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    // create inner rectangle smaller by strokeWidth
    Rect innerRect = Rect.fromLTWH(strokeWidth, strokeWidth,
        size.width - strokeWidth * 2, size.height - strokeWidth * 2);
    var innerRRect = RRect.fromRectAndRadius(
        innerRect, Radius.circular(radius - strokeWidth));

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    Path path1 = Path()..addRRect(outerRRect);
    Path path2 = Path()..addRRect(innerRRect);
    var path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

/// [CapsuleView] creates capsule shape widget - Bordered view with rounded corners.
class _CapsuleView extends StatelessWidget {
  const _CapsuleView({
    Key? key,
    required this.left,
    required this.height,
    required this.width,
    required this.color,
  }) : super(key: key);

  final double left;
  final double height;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -0.5,
      bottom: -0.5,
      left: left,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.all(Radius.circular(height / 2.0)),
        ),
      ),
    );
  }
}

/// Widget to show diamond shape with [CustomPaint]
class _DiamondView extends StatelessWidget {
  const _DiamondView(
      {Key? key,
      required this.size,
      required this.left,
      required this.degree,
      required this.color})
      : super(key: key);

  final double size;
  final double left;
  final double degree;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: CustomPaint(
        child: SizedBox(
          width: size,
          height: size,
        ),
        painter: _DiamondPainter(degree, color),
      ),
    );
  }
}

/// [CustomPainter] to create diamond shape
class _DiamondPainter extends CustomPainter {
  _DiamondPainter(this.degree, this.color);

  final double degree;
  final Color color;

  Offset offset1(Size size) {
    return Offset(size.width / 2, 0);
  }

  Offset offset2(Size size) {
    return Offset(size.width, size.height / 2.0);
  }

  Offset offset3(Size size) {
    return Offset(size.width / 2, size.height);
  }

  Offset offset4(Size size) {
    return Offset(0, size.height / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.translate(size.width / 2, size.height / 2);
    // rotate the canvas
    final radians = degree * pi / 180;
    canvas.rotate(radians);
    canvas.translate(-size.width / 2, -size.height / 2);

    var paint = Paint()..color = color;

    final centerControlPoint = size.width / 2;
    final point1 = offset1(size);
    final point2 = offset2(size);
    final point3 = offset3(size);
    final point4 = offset4(size);

    final path = Path()
      ..moveTo(point1.dx, point1.dy)
      ..quadraticBezierTo(
        centerControlPoint,
        centerControlPoint,
        point2.dx,
        point2.dy,
      )
      ..lineTo(point2.dx, point2.dy)
      ..quadraticBezierTo(
          centerControlPoint, centerControlPoint, point3.dx, point3.dy)
      ..lineTo(point3.dx, point3.dy)
      ..quadraticBezierTo(
          centerControlPoint, centerControlPoint, point4.dx, point4.dy)
      ..lineTo(point4.dx, point4.dy)
      ..quadraticBezierTo(
          centerControlPoint, centerControlPoint, point1.dx, point1.dy)
      ..close();

    canvas.drawPath(path, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
