import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart' as p;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/pages/image_adjust.dart';
import 'package:scanner/widgets/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFView extends StatefulWidget {
  @override
  _PDFViewState createState() => _PDFViewState(path);
  String path;
  PdfDocument pdf;
  PDFView(this.path, this.pdf);
}

class _PDFViewState extends State<PDFView> {
  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print('permission   $info');
  }

  initState() {
    _requestPermission();
    super.initState();
  }

  Future start() async {
    var dir = await getExternalStorageDirectory();
    var scanDir =
        await new io.Directory('${dir.path}/Scan').create(recursive: true);
  }

  var _imagePicker = ImagePicker();
  io.File _image;
  String path;
  _PDFViewState(this.path);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Text('Preview'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: FaIcon(FontAwesomeIcons.plusCircle),
              onPressed: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setBool('check', true);
                _getImage(ImageSource.camera);
              }),
          IconButton(
              icon: FaIcon(FontAwesomeIcons.save),
              onPressed: () async {
                print('saving');
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CusDialog(widget.pdf);
                    });
              }),
        ],
      ),
      body: Container(
        child: p.PDFView(
          filePath: path,
        ),
      ),
    );
  }
}
