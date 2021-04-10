import 'dart:io' as io;
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/pages/image_adjust.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scanner/widgets/ImgSourceDialog.dart';
import 'package:scanner/widgets/contants.dart';
import 'package:scanner/widgets/showpdf.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ImageCapture extends StatefulWidget {
  final PdfDocument document = PdfDocument();
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  io.File _image;

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
  void get() async {
    try {
      directory = (await getApplicationDocumentsDirectory()).path;
      setState(() {
        file = io.Directory("$directory/scan/").listSync();
      });
    } catch (e) {
      print(e);
    }
    print('file: $file');
  }

  @override
  void initState() {
    super.initState();
    get();
  }

  @override
  Widget build(BuildContext context) {
    var lrPadding = MediaQuery.of(context).size.width * 0.05;
    return Container(
      key: _scaffoldKey,
      // color: Color.fromRGBO(58, 66, 86, 1.0),
      child: Center(
        child: Column(
          children: [
            // Padding(
            //   padding: EdgeInsets.only(top: 8, left: lrPadding),
            //   child: Text(
            //     'Your',
            //     style: TextStyle(
            //       fontSize: 40,
            //       fontWeight: FontWeight.bold,
            //       color: Color.fromRGBO(58, 66, 86, 1.0),
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.only(left: lrPadding),
            //   child: Text(
            //     'Documents',
            //     style: TextStyle(
            //       fontSize: 40,
            //       fontWeight: FontWeight.bold,
            //       color: Color.fromRGBO(58, 66, 86, 1.0),
            //     ),
            //   ),
            // ),
            Expanded(
              flex: 1,
              child: file.length != 0
                  ? ListView.builder(
                      itemCount: file.length,
                      itemBuilder: (BuildContext context, int index) {
                        var name = file[index].toString().split("/");
                        String fName =
                            name[name.length - 1].replaceAll("'", "");
                        print(fName);
                        return Card(
                          color: Color.fromRGBO(58, 66, 86, 1.0),
                          // color: Colors.blue,
                          child: ExpansionTile(
                            childrenPadding: EdgeInsets.only(
                                left: 30, bottom: 10, right: 30),
                            title: Text(
                              fName,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 21),
                            ),
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PDFshow(file[index])));
                                      },
                                      child: Text(
                                        'Open',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Color.fromRGBO(38, 46, 66, 1.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      onPressed: () async {
                                        Uint8List pfile =
                                            await file[index].readAsBytes();
                                        await Share.file('Pdf Document', fName,
                                            pfile, '*/*');
                                      },
                                      child: Text(
                                        'Share',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Color.fromRGBO(38, 46, 66, 1.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      onPressed: () async {
                                        print('delete');
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return DeleteDialog(
                                                  file[index], this);
                                            });
                                      },
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Color.fromRGBO(38, 46, 66, 1.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      })
                  : Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.35),
                      child: Text(
                        'No files',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromRGBO(58, 66, 86, 1.0),
                        ),
                      ),
                    ),
              // child: Padding(
              //   padding: EdgeInsets.only(
              //       left: lrPadding,
              //       right: lrPadding,
              //       bottom: MediaQuery.of(context).size.height * 0.4,
              //       top: MediaQuery.of(context).size.height * 0.05),
              //   child: Container(
              //     width: MediaQuery.of(context).size.width,
              //     child: Card(
              //       shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(30)),
              //       color: Colors.blue,
              //       child: Column(
              //         // mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           IconButton(
              //             onPressed: () {
              //               showDialog(
              //                   context: context,
              //                   builder: (BuildContext context) {
              //                     return ImgsrcDialog();
              //                   });
              //             },
              //             icon: Icon(
              //               Icons.add_circle,
              //               size: 70,
              //               color: Colors.white,
              //             ),
              //           ),
              //           Text('hello')
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ),
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
                      height: MediaQuery.of(context).size.height * 0.04,
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
    );
  }
}

class DeleteDialog extends StatefulWidget {
  io.File f;
  _ImageCaptureState imgstate;
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
