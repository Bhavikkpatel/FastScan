import 'dart:io' as io;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scanner/pages/image_adjust.dart';
import 'package:scanner/pages/rearrange.dart';
import 'package:scanner/widgets/ImgSourceDialog.dart';
import 'package:scanner/widgets/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFView extends StatefulWidget {
  @override
  _PDFViewState createState() => _PDFViewState(images);
  String path;
  PdfDocument pdf;
  List<dynamic> images;
  double height, width;
  PDFView(this.path, this.pdf, this.images, this.height, this.width);
}

class _PDFViewState extends State<PDFView> {
  List<dynamic> imagesList;
  _PDFViewState(this.imagesList);
  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print('permission   $info');
  }

  initState() {
    _requestPermission();
    add();
    super.initState();
  }

  var images = <Widget>[];
  void add() {
    for (int i = 0; i < widget.images.length; i++) {
      Widget container = Container(
        height: widget.height,
        width: widget.width,
        child: Image.memory(widget.images[i]),
      );
      images.add(container);
    }
  }

  var _imagePicker = ImagePicker();
  io.File _image;

  _getImage(ImageSource imageSource) async {
    try {
      PickedFile imageFile = await _imagePicker.getImage(source: imageSource);
      if (imageFile == null) return;
      setState(() {
        _image = io.File(imageFile.path);
      });
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AdjustImage(_image, context)));
    } catch (e) {
      print('Error occurred -> $e');
    }
  }

  int pageindex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 30,
            ),
            onPressed: () {
              if (images.length == 0) {
                _getImage(ImageSource.camera);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          title: Text('Preview'),
          centerTitle: true,
          actions: [
            // IconButton(
            //     icon: Icon(
            //       LineIcons.plus,
            //       size: 30,
            //     ),
            //     onPressed: () async {
            //       SharedPreferences pref =
            //           await SharedPreferences.getInstance();
            //       pref.setBool('check', true);
            //       // _getImage(ImageSource.camera);
            //       showDialog(
            //           context: context,
            //           builder: (BuildContext context) {
            //             return ImgsrcDialog();
            //           });
            //     }),
            IconButton(
                icon: Icon(
                  Icons.save_alt_rounded,
                  size: 30,
                ),
                onPressed: () async {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (contect) => Rearrange(
                  //             widget.images,
                  //             MediaQuery.of(context).size.height * 0.3,
                  //             MediaQuery.of(context).size.width * 0.3)));
                  PdfDocument pdf = PdfDocument();
                  for (int i = 0; i < widget.images.length; i++) {
                    // print(img[i]);
                    PdfPage page = pdf.pages.add();
                    page.graphics.drawImage(
                        PdfBitmap(imagesList[i]),
                        Rect.fromLTWH(0, 0, page.getClientSize().width,
                            page.getClientSize().height));
                  }
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CusDialog(pdf);
                      });
                }),
          ],
        ),
        body: Container(
          color: Colors.grey[300],
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    pauseAutoPlayOnManualNavigate: true,
                    height: widget.height,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    initialPage: 1,
                    autoPlay: false,
                    onPageChanged: (index, just) {
                      print(index);
                      setState(() {
                        pageindex = index;
                      });
                    },
                  ),
                  items: images,
                ),
                ClipOval(
                  child: Material(
                    color: Color.fromRGBO(30, 40, 60, 1.0), // button color
                    child: InkWell(
                      splashColor: Colors.red, // inkwell color
                      child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          )),
                      onTap: () {
                        setState(() {
                          images.removeAt(pageindex);
                          imagesList.removeAt(pageindex);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
