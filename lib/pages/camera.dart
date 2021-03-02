import 'dart:io' as io;
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/pages/image_adjust.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scanner/widgets/showpdf.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ImageCapture extends StatefulWidget {
  final PdfDocument document = PdfDocument();
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
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
    return Container(
      color: Color.fromRGBO(58, 66, 86, 1.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
                        return FocusedMenuHolder(
                          menuWidth: MediaQuery.of(context).size.width * 0.5,
                          leftOffset: 20,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PDFshow(file[index])));
                          },
                          menuItems: <FocusedMenuItem>[
                            FocusedMenuItem(
                                title: Text('Open'),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PDFshow(file[index])));
                                }),
                            FocusedMenuItem(
                                title: Text('share'),
                                onPressed: () async {
                                  print('share');
                                  Uint8List pfile =
                                      await file[index].readAsBytes();
                                  await Share.file(
                                      'Pdf Document', fName, pfile, '*/*');
                                }),
                            FocusedMenuItem(
                                title: Text('delete'),
                                onPressed: () async {
                                  print('delete');
                                  io.File f = file[index];
                                  print('delete: $f');
                                  await f.delete(recursive: true);
                                  setState(() {
                                    get();
                                  });
                                }),
                          ],
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            leading: Container(
                              padding: EdgeInsets.only(right: 12.0),
                              decoration: new BoxDecoration(
                                  border: new Border(
                                      right: new BorderSide(
                                          width: 1.0, color: Colors.white24))),
                              child: Icon(Icons.picture_as_pdf_outlined,
                                  color: Colors.white),
                            ),
                            title: Text(
                              fName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                            subtitle: Row(
                              children: <Widget>[
                                Text("", style: TextStyle(color: Colors.white))
                              ],
                            ),
                          ),
                        );
                      })
                  : Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.35),
                      child: Text(
                        'No files',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: FloatingActionButton.extended(
                elevation: 15,
                backgroundColor: Color.fromRGBO(70, 80, 100, 1.0),
                onPressed: () {},
                label: Row(
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
