import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:scanner/pages/showImage.dart';
import 'package:scanner/widgets/cropper.dart';

class AdjustImage extends StatefulWidget {
  final File file;
  final BuildContext context;
  AdjustImage(this.file, this.context);
  @override
  _AdjustImageState createState() => _AdjustImageState();
}

class _AdjustImageState extends State<AdjustImage> {
  final GlobalKey key = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Size imagePixelSize;
  double width, height;
  bool isFile = false, isloading = true;
  Offset tl, tr, bl, br;
  bool isLoading = false;
  double screenHeight, screenWidth;
  void getImageSize() async {
    RenderBox imageBox = key.currentContext.findRenderObject();
    width = imageBox.size.width;
    height = imageBox.size.height;
    print('$height           $width');
    imagePixelSize = ImageSizGetter.getSize(widget.file);
    print('${imagePixelSize.height}     ${imagePixelSize.width}');
    tl = new Offset(20, 20);
    tr = new Offset(width - 20, 20);
    bl = new Offset(20, height - 20);
    br = new Offset(width - 20, height - 20);
    setState(() {
      isFile = true;
      isloading = false;
      // FocusScope.of(context).previousFocus();
    });
  }

  @override
  void initState() {
    super.initState();
    // FocusScope.of(context).unfocus();
    Timer(Duration(seconds: 2), getImageSize);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
            centerTitle: true,
            title: Text('Adjust'),
            actions: [
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {
                  Timer(Duration(seconds: 1), () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ShowImage(
                              tl: tl,
                              tr: tr,
                              bl: bl,
                              br: br,
                              width: width,
                              height: height,
                              file: widget.file,
                              imagePixelSize: imagePixelSize,
                            )));
                  });
                },
              ),
            ],
          ),
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          key: _scaffoldKey,
          body: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Stack(
                      children: <Widget>[
                        GestureDetector(
                          onPanDown: (details) {
                            double x1 = details.localPosition.dx;
                            double y1 = details.localPosition.dy;
                            double x2 = tl.dx;
                            double y2 = tl.dy;
                            double x3 = tr.dx;
                            double y3 = tr.dy;
                            double x4 = bl.dx;
                            double y4 = bl.dy;
                            double x5 = br.dx;
                            double y5 = br.dy;
                            if (sqrt((x2 - x1) * (x2 - x1) +
                                        (y2 - y1) * (y2 - y1)) <
                                    30 &&
                                x1 >= 0 &&
                                y1 >= 0 &&
                                x1 < width / 2 &&
                                y1 < height / 2) {
                              print(details.localPosition);
                              setState(() {
                                tl = details.localPosition;
                              });
                            } else if (sqrt((x3 - x1) * (x3 - x1) +
                                        (y3 - y1) * (y3 - y1)) <
                                    30 &&
                                x1 >= width / 2 &&
                                y1 >= 0 &&
                                x1 < width &&
                                y1 < height / 2) {
                              setState(() {
                                tr = details.localPosition;
                              });
                            } else if (sqrt((x4 - x1) * (x4 - x1) +
                                        (y4 - y1) * (y4 - y1)) <
                                    30 &&
                                x1 >= 0 &&
                                y1 >= height / 2 &&
                                x1 < width / 2 &&
                                y1 < height) {
                              setState(() {
                                bl = details.localPosition;
                              });
                            } else if (sqrt((x5 - x1) * (x5 - x1) +
                                        (y5 - y1) * (y5 - y1)) <
                                    30 &&
                                x1 >= width / 2 &&
                                y1 >= height / 2 &&
                                x1 < width &&
                                y1 < height) {
                              setState(() {
                                br = details.localPosition;
                              });
                            }
                          },
                          onPanUpdate: (details) {
                            double x1 = details.localPosition.dx;
                            double y1 = details.localPosition.dy;
                            double x2 = tl.dx;
                            double y2 = tl.dy;
                            double x3 = tr.dx;
                            double y3 = tr.dy;
                            double x4 = bl.dx;
                            double y4 = bl.dy;
                            double x5 = br.dx;
                            double y5 = br.dy;
                            if (sqrt((x2 - x1) * (x2 - x1) +
                                        (y2 - y1) * (y2 - y1)) <
                                    30 &&
                                x1 >= 0 &&
                                y1 >= 0 &&
                                x1 < width / 2 &&
                                y1 < height / 2) {
                              print(details.localPosition);
                              setState(() {
                                tl = details.localPosition;
                              });
                            } else if (sqrt((x3 - x1) * (x3 - x1) +
                                        (y3 - y1) * (y3 - y1)) <
                                    30 &&
                                x1 >= width / 2 &&
                                y1 >= 0 &&
                                x1 < width &&
                                y1 < height / 2) {
                              setState(() {
                                tr = details.localPosition;
                              });
                            } else if (sqrt((x4 - x1) * (x4 - x1) +
                                        (y4 - y1) * (y4 - y1)) <
                                    30 &&
                                x1 >= 0 &&
                                y1 >= height / 2 &&
                                x1 < width / 2 &&
                                y1 < height) {
                              setState(() {
                                bl = details.localPosition;
                              });
                            } else if (sqrt((x5 - x1) * (x5 - x1) +
                                        (y5 - y1) * (y5 - y1)) <
                                    30 &&
                                x1 >= width / 2 &&
                                y1 >= height / 2 &&
                                x1 < width &&
                                y1 < height) {
                              setState(() {
                                br = details.localPosition;
                              });
                            }
                          },
                          child: Container(
                            color: ThemeData.dark().canvasColor,
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.9,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.7),
                            child: Image.file(
                              widget.file,
                              key: key,
                            ),
                          ),
                        ),
                        isFile
                            ? CustomPaint(
                                painter: Cropper(tl, tr, bl, br),
                              )
                            : Container()
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
