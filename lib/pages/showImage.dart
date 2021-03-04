import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/pages/image_adjust.dart';
import 'package:scanner/widgets/ImgSourceDialog.dart';
import 'package:scanner/widgets/loading.dart';
import 'package:scanner/widgets/pdfpreview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ShowImage extends StatefulWidget {
  io.File file;
  var imagePixelSize;
  double width;
  double height;
  Offset tl, tr, bl, br;
  GlobalKey<AnimatedListState> animatedListKey;
  ShowImage(
      {this.file,
      this.bl,
      this.br,
      this.tl,
      this.height,
      this.tr,
      this.imagePixelSize,
      this.width,
      this.animatedListKey});
  @override
  _ShowImageState createState() => _ShowImageState();
}

PdfDocument pdf = new PdfDocument();
List<dynamic> allimg = [];

class _ShowImageState extends State<ShowImage> {
  final _focusNode = FocusNode();
  MethodChannel channel = new MethodChannel('opencv');
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 0;
  bool isBottomOpened = false;
  PersistentBottomSheetController controller;
  var whiteboardBytes;
  var originalBytes;
  var grayBytes;
  bool isGrayBytes = false;
  bool isOriginalBytes = false;
  bool isWhiteBoardBytes = false;
  bool isRotating = false;
  int angle = 0;
  String canvasType = "whiteboard";
  double tl_x;
  double tr_x;
  double bl_x;
  double br_x;
  double tl_y;
  double tr_y;
  double bl_y;
  double br_y;
  var bytes;
  void check() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool('check') == false) {
      // print('pref.getBool() = ${pref.getBool('check')}');
      pdf = new PdfDocument();
      allimg = [];
    }
  }

  bool added = false;
  bool Sadded = false;
  @override
  void initState() {
    super.initState();
    check();
    tl_x = (widget.imagePixelSize.width / widget.width) * widget.tl.dx;
    tr_x = (widget.imagePixelSize.width / widget.width) * widget.tr.dx;
    bl_x = (widget.imagePixelSize.width / widget.width) * widget.bl.dx;
    br_x = (widget.imagePixelSize.width / widget.width) * widget.br.dx;

    tl_y = (widget.imagePixelSize.height / widget.height) * widget.tl.dy;
    tr_y = (widget.imagePixelSize.height / widget.height) * widget.tr.dy;
    bl_y = (widget.imagePixelSize.height / widget.height) * widget.bl.dy;
    br_y = (widget.imagePixelSize.height / widget.height) * widget.br.dy;
    convertToGray();
    filter();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<dynamic> images = [];
  var _imagePicker = ImagePicker();
  io.File _image;
  String path;
  _getImage(ImageSource imageSource) async {
    try {
      PickedFile imageFile = await _imagePicker.getImage(source: imageSource);
      if (imageFile == null) return;
      setState(() {
        _image = io.File(imageFile.path);
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AdjustImage(_image, context)));
    } catch (e) {
      // print('Error occurred -> $e');
    }
  }

  int filter_index = 1;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: filter_index,
          onTap: (index) {
            // print(index);
            setState(() {
              filter_index = index;
              bytes = images[filter_index];
            });
            // print(bytes);
          },
          selectedItemColor: Colors.white,
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                LineIcons.filter,
                size: 30,
              ),
              label: 'original',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                LineIcons.filter,
                size: 30,
              ),
              label: 'White Board',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                LineIcons.filter,
                size: 30,
              ),
              label: 'grey',
            )
          ],
        ),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              LineIcons.arrowLeft,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          centerTitle: true,
          title: Text('Filters'),
          actions: [
            IconButton(
                icon: Icon(
                  LineIcons.plus,
                  size: 30,
                ),
                onPressed: () async {
                  if (!Sadded) {
                    setState(() {
                      loading = true;
                      // print('adding');
                    });
                    allimg.add(bytes);
                    PdfPage page = pdf.pages.add();
                    page.graphics.drawImage(
                        PdfBitmap(bytes),
                        Rect.fromLTWH(0, 0, page.getClientSize().width,
                            page.getClientSize().height));
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.setBool('check', true); // ongoing
                    setState(() {
                      loading = false;
                      // print('added');
                      Sadded = true;
                    });
                  }
                  // _getImage(ImageSource.camera);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ImgsrcDialog();
                      });
                }),
            IconButton(
                icon: Icon(
                  LineIcons.arrowRight,
                  size: 30,
                ),
                onPressed: () async {
                  if (!Sadded) {
                    // print('adding');
                    PdfPage page = pdf.pages.add();
                    page.graphics.drawImage(
                        PdfBitmap(bytes),
                        Rect.fromLTWH(0, 0, page.getClientSize().width,
                            page.getClientSize().height));
                    allimg.add(bytes);
                    setState(() {
                      Sadded = true;
                    });
                  }
                  io.Directory dc = await getTemporaryDirectory();
                  String documentPath = dc.path;
                  io.File file = io.File("$documentPath/record1.pdf");
                  file.writeAsBytes(pdf.save());
                  String fullPath = "$documentPath/record1.pdf";
                  // print(fullPath);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PDFView(
                              fullPath,
                              pdf,
                              allimg,
                              MediaQuery.of(context).size.height * 0.7,
                              MediaQuery.of(context).size.width * 0.7)));
                  // print('displayed');
                }),
          ],
        ),
        key: scaffoldKey,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          elevation: 15,
          child: Icon(
            Icons.rotate_right,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              isRotating = true;
            });
            var nBytes;
            Timer(Duration(seconds: 1), () async {
              bytes = await channel
                  .invokeMethod('rotate', {"bytes": bytes}).then((value) {
                Timer(Duration(seconds: 3), () async {
                  if (angle == 360) {
                    angle = 0;
                  }
                  angle = angle + 90;
                  var nbytes = await channel
                      .invokeMethod('rotateCompleted', {"bytes": bytes});
                  setState(() {
                    bytes = nbytes;
                    isRotating = false;
                  });
                });
              });
            });
          },
        ),
        backgroundColor: Colors.grey[300],
        body: Container(
          color: Color.fromRGBO(58, 66, 86, 1.0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: loading || isRotating
                ? loadingCircle()
                : Container(
                    height: MediaQuery.of(context).size.height,
                    child: bytes != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              bytes == null
                                  ? Container()
                                  : Center(
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              maxHeight: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.7),
                                          child: Image.memory(bytes)),
                                    ),
                            ],
                          )
                        : Center(child: loadingCircle()),
                  ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> convertToGray() async {
    var bytesArray = await channel.invokeMethod('convertToGray', {
      'filePath': widget.file.path,
      'tl_x': tl_x,
      'tl_y': tl_y,
      'tr_x': tr_x,
      'tr_y': tr_y,
      'bl_x': bl_x,
      'bl_y': bl_y,
      'br_x': br_x,
      'br_y': br_y,
    });
    setState(() {
      bytes = bytesArray;
      whiteboardBytes = bytesArray;
    });
    return bytesArray;
  }

  Future<void> grayandoriginal() async {
    Future.delayed(Duration(seconds: 1), () {
      channel.invokeMethod('gray', {
        'filePath': widget.file.path,
        'tl_x': tl_x,
        'tl_y': tl_y,
        'tr_x': tr_x,
        'tr_y': tr_y,
        'bl_x': bl_x,
        'bl_y': bl_y,
        'br_x': br_x,
        'br_y': br_y,
      });
      channel.invokeMethod('whiteboard', {
        'filePath': widget.file.path,
        'tl_x': tl_x,
        'tl_y': tl_y,
        'tr_x': tr_x,
        'tr_y': tr_y,
        'bl_x': bl_x,
        'bl_y': bl_y,
        'br_x': br_x,
        'br_y': br_y,
      });
      channel.invokeMethod('original', {
        'filePath': widget.file.path,
        'tl_x': tl_x,
        'tl_y': tl_y,
        'tr_x': tr_x,
        'tr_y': tr_y,
        'bl_x': bl_x,
        'bl_y': bl_y,
        'br_x': br_x,
        'br_y': br_y,
      });
    });
    Timer(Duration(seconds: 7), () async {
      // print("this started");
      await channel.invokeMethod('grayCompleted').then((value) {
        grayBytes = value;
        isGrayBytes = true;
      });
      await channel.invokeMethod('whiteboardCompleted').then((value) {
        whiteboardBytes = value;
        isWhiteBoardBytes = true;
      });
      await channel.invokeMethod('originalCompleted').then((value) {
        originalBytes = value;
        isOriginalBytes = true;
      });
      images.add(originalBytes);
      images.add(whiteboardBytes);
      images.add(grayBytes);
      setState(() {
        loading = false;
      });
      // print('loading:  $loading');
    });
  }

  void filter() {
    if (isOriginalBytes == false) {
      setState(() {
        loading = true;
      });
      // print('loading:  $loading');
      grayandoriginal();
    }
  }
}
