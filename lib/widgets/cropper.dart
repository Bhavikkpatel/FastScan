import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Cropper extends CustomPainter {
  Offset tl, tr, bl, br;
  Cropper(this.tl, this.tr, this.bl, this.br);
  Paint painter = Paint()
    ..color = Colors.red
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  Paint painter1 = Paint()
    ..color = Colors.red
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(tl, 15, painter);
    canvas.drawCircle(tr, 15, painter);
    canvas.drawCircle(bl, 15, painter);
    canvas.drawCircle(br, 15, painter);
    canvas.drawLine(tl, tr, painter1);
    canvas.drawLine(tr, br, painter1);
    canvas.drawLine(br, bl, painter1);
    canvas.drawLine(bl, tl, painter1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
