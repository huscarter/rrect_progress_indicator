

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 扇形进度条
class RRectProgressIndicator extends StatefulWidget {
  final double arcWidth;

  final double value;

  final Color backgroundColor;

  /// [ThemeData.accentColor].
  final Animation<Color> valueColor;

  final String semanticsLabel;

  final String semanticsValue;

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Theme.of(context).accentColor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(PercentProperty('value', value,
        showName: false, ifNull: '<indeterminate>'));
  }

  const RRectProgressIndicator({
    Key key,
    this.value,
    this.backgroundColor,
    this.strokeWidth = 4.0,
    this.arcWidth = 80,
    this.valueColor,
    this.semanticsLabel,
    this.semanticsValue,
  }) : super(key: key);

  /// The width of the line used to draw the circle.
  final double strokeWidth;

  @override
  _RRectProgressIndicatorState createState() => _RRectProgressIndicatorState();
}

class _RRectProgressIndicatorState extends State<RRectProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  ///
  double wrapWidth;

  @override
  void initState() {
    super.initState();

    wrapWidth = math.sqrt2 * widget.arcWidth;

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    if (widget.value == null) _controller.repeat();
  }

  @override
  void didUpdateWidget(RRectProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating)
      _controller.repeat();
    else if (widget.value != null && _controller.isAnimating)
      _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.arcWidth,
      height: widget.arcWidth,
      child: CustomPaint(
        painter: _RRectProgressIndicatorPainter(
          backgroundColor: widget.backgroundColor,
          valueColor: widget._getValueColor(context),
          value: widget.value,
          strokeWidth: widget.strokeWidth,
          arcWidth: widget.arcWidth,
          wrapWidth: wrapWidth,
        ),
      ),
    );
  }
}

class _RRectProgressIndicatorPainter extends CustomPainter {
  _RRectProgressIndicatorPainter({
    this.backgroundColor,
    this.valueColor,
    this.value,
    this.headValue,
    this.tailValue,
    this.stepValue,
    this.arcWidth,
    this.wrapWidth,
    this.rotationValue,
    this.strokeWidth,
  })  : arcStart = value != null
            ? _startAngle
            : _startAngle +
                tailValue * 3 / 2 * math.pi +
                rotationValue * math.pi * 1.7 -
                stepValue * 0.8 * math.pi,
        arcSweep = value != null
            ? value.clamp(0.0, 1.0) * _sweep
            : math.max(
                headValue * 3 / 2 * math.pi - tailValue * 3 / 2 * math.pi,
                _epsilon),
        position = wrapWidth / 2 - arcWidth / 2;

  final Color backgroundColor;
  final Color valueColor;
  final double value;
  final double headValue;
  final double tailValue;
  final int stepValue;
  final double rotationValue;
  final double strokeWidth;
  final double arcStart;
  final double arcSweep;
  final double arcWidth;
  final double wrapWidth;
  final double position;

  static const double _twoPi = math.pi * 2.0;
  static const double _epsilon = .001;

  // Canvas.drawArc(r, 0, 2*PI) doesn't draw anything, so just get close.
  static const double _sweep = _twoPi - _epsilon;
  static const double _startAngle = -math.pi / 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    // 圆角矩形限制
    canvas.clipRRect(RRect.fromLTRBR(position, position, position + arcWidth,
        position + arcWidth, Radius.circular(5)));
    // 画笔设置
    final Paint paint = Paint()
      ..color = valueColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.fill;
    // 制画
    canvas.drawArc(Offset.zero & Size(wrapWidth, wrapWidth),
        arcSweep + _startAngle, _twoPi - arcSweep, true, paint);
  }

  @override
  bool shouldRepaint(_RRectProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.headValue != headValue ||
        oldPainter.tailValue != tailValue ||
        oldPainter.stepValue != stepValue ||
        oldPainter.rotationValue != rotationValue ||
        oldPainter.strokeWidth != strokeWidth;
  }
}
