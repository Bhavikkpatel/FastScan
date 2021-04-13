import 'dart:async';
import 'dart:io' as io;
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/pages/image_adjust.dart';
import 'package:scanner/pages/rearrange.dart';
import 'package:scanner/widgets/ImgSourceDialog.dart';
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
  var _currentIndex = 2;
  var pageindex;
  var allImages = <Widget>[];
  List<dynamic> allRotate = [];
  void add() {
    Timer(Duration(seconds: 2), () {
      for (int i = 0; i < allimg.length; i++) {
        Widget container = Container(
          height: widget.height,
          width: widget.width,
          child: Image.memory(allimg[i]),
        );
        setState(() {
          allImages.add(container);
        });
      }
    });
  }

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
    setState(() {
      pageindex = allimg.length;
    });
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
    } catch (e) {}
  }

  int filter_index = 1;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: bottomNavBar(),
        appBar: AppBar(
          leadingWidth: MediaQuery.of(context).size.width * 0.1,
          backgroundColor: Colors.white,
          title: Text(
            'Edit',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              size: 30,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.save_alt_rounded,
                  color: Colors.black,
                ),
                onPressed: NaviagteToPreview)
          ],
        ),
        key: scaffoldKey,
        backgroundColor: Colors.grey[300],
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: (loading || isRotating)
                ? SpinKitDoubleBounce(
                    color: Colors.blue,
                  )
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
                        : Center(
                            child: SpinKitDoubleBounce(
                            color: Colors.blue,
                          )),
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
    });
  }

  void filter() {
    if (isOriginalBytes == false) {
      setState(() {
        loading = true;
      });
      grayandoriginal();
    }
  }

  FFNavigationBar bottomNavBar() {
    return FFNavigationBar(
      theme: FFNavigationBarTheme(
        barBackgroundColor: Colors.white,
        selectedItemBackgroundColor: Colors.blue,
        selectedItemIconColor: Colors.white,
        selectedItemLabelColor: Colors.black,
      ),
      selectedIndex: _currentIndex,
      onSelectTab: (index) {
        setState(() {
          _currentIndex = index;
        });
        if (_currentIndex == 2) {
          colorOptions();
        } else if (_currentIndex == 0) {
          addOption();
        } else if (_currentIndex == 1) {
          navigateToAdjustImage();
        } else if (_currentIndex == 3) {
          NaviagteToReorder();
        } else if (_currentIndex == 4) {
          setState(() {
            isRotating = true;
          });
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
        }
      },
      items: [
        FFNavigationBarItem(
          iconData: Icons.add_circle,
          label: 'Add Page',
        ),
        FFNavigationBarItem(
          iconData: Icons.crop,
          label: 'Crop',
        ),
        FFNavigationBarItem(
          iconData: Icons.format_paint_outlined,
          label: 'Colors',
        ),
        FFNavigationBarItem(
          iconData: Icons.reorder,
          label: 'Reorder',
        ),
        FFNavigationBarItem(
          iconData: Icons.rotate_right,
          label: 'Rotate',
        ),
      ],
    );
  }

  void colorOptions() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        bytes = images[0];
                      });
                      Navigator.pop(context);
                    },
                    child: filterContainer(0)),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        bytes = images[1];
                      });
                      Navigator.pop(context);
                    },
                    child: filterContainer(1)),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        bytes = images[2];
                      });
                      Navigator.pop(context);
                    },
                    child: filterContainer(2)),
              ],
            ),
          );
        });
  }

  Widget filterContainer(index) {
    return Container(
      width: 130,
      child: Image.memory(images[index]),
    );
  }

  void rotateOptions() {
    print(allRotate.length);
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        bytes = allRotate[0];
                      });
                      Navigator.pop(context);
                    },
                    child: RotateContainer(0)),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        bytes = allRotate[1];
                      });
                      Navigator.pop(context);
                    },
                    child: RotateContainer(1)),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        bytes = allRotate[2];
                      });
                      Navigator.pop(context);
                    },
                    child: RotateContainer(2)),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        bytes = allRotate[3];
                      });
                      Navigator.pop(context);
                    },
                    child: RotateContainer(3)),
              ],
            ),
          );
        });
  }

  Widget RotateContainer(index) {
    return Container(
      width: 130,
      child: Image.memory(allRotate[index]),
    );
  }

  void addPage() async {
    if (!Sadded) {
      setState(() {
        loading = true;
      });
      allimg.add(bytes);
      PdfPage page = pdf.pages.add();
      page.graphics.drawImage(
          PdfBitmap(bytes),
          Rect.fromLTWH(
              0, 0, page.getClientSize().width, page.getClientSize().height));
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool('check', true); // ongoing
      setState(() {
        loading = false;
        Sadded = true;
      });
    }
    // _getImage(ImageSource.camera);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ImgsrcDialog();
        });
  }

  void navigateToAdjustImage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AdjustImage(widget.file, context)));
  }

  dynamic rotate() async {
    var nbytes, abytes;
    Timer(Duration(seconds: 1), () async {
      abytes =
          await channel.invokeMethod('rotate', {"bytes": bytes}).then((value) {
        Timer(Duration(seconds: 3), () async {
          if (angle == 360) {
            angle = 0;
          }
          angle = angle + 90;
          nbytes =
              await channel.invokeMethod('rotateCompleted', {"bytes": bytes});
        });
      });
    });
    return nbytes;
  }

  void NaviagteToReorder() async {
    if (Sadded == false) {
      setState(() {
        allimg.add(bytes);
        Sadded = true;
      });
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (contect) => Rearrange(
                allimg,
                MediaQuery.of(context).size.height * 0.3,
                MediaQuery.of(context).size.width * 0.3)));
  }

  void NaviagteToPreview() async {
    if (!Sadded) {
      PdfPage page = pdf.pages.add();
      page.graphics.drawImage(
          PdfBitmap(bytes),
          Rect.fromLTWH(
              0, 0, page.getClientSize().width, page.getClientSize().height));
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFView(
                fullPath,
                pdf,
                allimg,
                MediaQuery.of(context).size.height * 0.7,
                MediaQuery.of(context).size.width * 0.7)));
  }

  void addOption() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('check', true);
    setState(() {
      allimg.add(bytes);
      Sadded = true;
    });
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _getImage(ImageSource.camera);
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.camera,
                      color: Colors.blue,
                    ),
                    title: Text(
                      'Camera',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _getImage(ImageSource.gallery);
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.image,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Gallery',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
