import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/pages/image_adjust.dart';
import 'package:scanner/widgets/contants.dart';
import 'package:scanner/widgets/showpdf.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart' as nativePdf;

class Home extends StatefulWidget {
  final PdfDocument document = PdfDocument();
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  io.File _image;
  bool loading = true;
  String directory;
  var _imagePicker = ImagePicker();
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

  List file = new List();
  List<dynamic> imgs = new List();
  void get() async {
    try {
      directory = (await getApplicationDocumentsDirectory()).path;
      setState(() {
        file = io.Directory("$directory/scan/").listSync();
      });
      for (int i = 0; i < file.length; i++) {
        final doc = await nativePdf.PdfDocument.openFile(file[i].path);
        final page = await doc.getPage(1);
        final pageImage =
            await page.render(width: page.width, height: page.height);
        imgs.add(pageImage.bytes);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    get();
    _controller = AnimationController(vsync: this);
  }

  Future<nativePdf.PdfPageImage> getImage(File pdf) async {
    final doc = await nativePdf.PdfDocument.openFile(pdf.path);
    final page = await doc.getPage(1);
    final pageImage = await page.render(width: page.width, height: page.height);
    return pageImage;
  }

  AnimationController _controller;
  @override
  Widget build(BuildContext context) {
    var leftPadding = MediaQuery.of(context).size.width * 0.03;
    var topPadding = MediaQuery.of(context).size.height * 0.01;
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      key: _scaffoldKey,
      child: loading
          ? Center(
              child: SpinKitRipple(
                color: Colors.blue,
                size: 80,
              ),
            )
          : Container(
              color: Color.fromRGBO(232, 232, 232, 1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: leftPadding, top: topPadding + 30),
                    child: Text(
                      'Your',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 40,
                        // fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(58, 66, 86, 1.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: leftPadding),
                    child: Text(
                      'Documents',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 40,
                        // fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(58, 66, 86, 1.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: topPadding,
                  ),
                  Divider(
                    color: Color.fromRGBO(232, 232, 232, 1.0),
                    thickness: 5,
                  ),
                  Expanded(
                      flex: 1,
                      child: file.length != 0
                          ? Container(
                              color: Color.fromRGBO(232, 232, 232, 1.0),
                              child: ListView.builder(
                                itemCount: file.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var name = file[index].toString().split("/");
                                  String fName =
                                      name[name.length - 1].replaceAll("'", "");
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    color: Color.fromRGBO(245, 245, 245, 1.0),
                                    child: Row(
                                      children: [
                                        Card(
                                          color: Color.fromRGBO(
                                              248, 248, 248, 1.0),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Image(
                                              image: MemoryImage(imgs[index]),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: leftPadding,
                                                      top: topPadding),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        fName,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Ubuntu'),
                                                      ),
                                                      Text(
                                                        '07/03/2021',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                            fontFamily:
                                                                'Ubuntu'),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                          Icons.file_present),
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    PDFshow(file[
                                                                        index])));
                                                      },
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.15,
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                          Icons.share_sharp),
                                                      onPressed: () async {
                                                        Uint8List pfile =
                                                            await file[index]
                                                                .readAsBytes();
                                                        await Share.file(
                                                            'Pdf Document',
                                                            fName,
                                                            pfile,
                                                            '*/*');
                                                      },
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.15,
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons
                                                          .delete_outline_sharp),
                                                      onPressed: () async {
                                                        // print('delete');
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return DeleteDialog(
                                                                  file[index],
                                                                  this);
                                                            });
                                                      },
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        Divider(
                                          // color: Color.fromRGBO(232, 232, 232, 1.0),
                                          color: Colors.white,
                                          thickness: 5,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Container(
                                  // height: 300,
                                  // width: 300,
                                  // child: Lottie.asset(
                                  //   "asset/animation/menu.json",
                                  //   // controller: _controller,
                                  //   // onLoaded: (composition) {
                                  //   //   _controller
                                  //   //     ..duration = composition.duration
                                  //   //     ..forward();
                                  //   // },
                                  // ),
                                  ),
                            )),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 20, top: 5),
                          child: FloatingActionButton.extended(
                            elevation: 15,
                            backgroundColor: Color.fromRGBO(70, 80, 100, 1.0),
                            onPressed: () {},
                            label: Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    icon: FaIcon(FontAwesomeIcons.camera),
                                    onPressed: () {
                                      print('camera');
                                      _getImage(ImageSource.camera);
                                    }),
                                Container(
                                  color: Colors.white,
                                  height:
                                      MediaQuery.of(context).size.height * 0.04,
                                  width: 2,
                                ),
                                IconButton(
                                    icon: FaIcon(FontAwesomeIcons.upload),
                                    onPressed: () {
                                      print('gallery');
                                      _getImage(ImageSource.gallery);
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class DeleteDialog extends StatefulWidget {
  io.File f;
  _HomeState imgstate;
  DeleteDialog(this.f, this.imgstate);

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  Future start() async {
    var dir = await getExternalStorageDirectory();
    var scanDir =
        await new io.Directory('${dir.path}/Scan').create(recursive: true);
  }

  Duration duration = const Duration(milliseconds: 500);
  TextEditingController fileName = TextEditingController();
  bool isShadow = true;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          padding: EdgeInsets.only(
              left: Constants.padding,
              top: Constants.avatarRadius + Constants.padding,
              right: Constants.padding,
              bottom: Constants.padding),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            children: <Widget>[
              Text(
                'Delete PDF',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15,
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xff5c5bb0),
                              )),
                          onPressed: () async {
                            await widget.f.delete(recursive: true);
                            widget.imgstate.setState(() {
                              widget.imgstate.get();
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Delete',
                            style: TextStyle(fontSize: 18),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xff5c5bb0),
                              )),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 18),
                          )),
                    ],
                  )),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.all(Radius.circular(Constants.avatarRadius)),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: Color.fromRGBO(58, 66, 86, 1.0),
                    size: MediaQuery.of(context).size.height * 0.07,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
