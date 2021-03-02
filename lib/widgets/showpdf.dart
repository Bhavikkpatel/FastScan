import 'dart:io';
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart' as p;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:scanner/widgets/loading.dart';

class PDFshow extends StatefulWidget {
  @override
  _PDFshowState createState() => _PDFshowState();
  File file;

  PDFshow(this.file);
}

class _PDFshowState extends State<PDFshow> {
  bool loading = true;
  PDFDocument doc;
  setPdf() async {
    PDFDocument pdf = await PDFDocument.fromFile(widget.file);
    setState(() {
      doc = pdf;
      loading = false;
    });
  }

  @override
  void initState() {
    setPdf();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var name = widget.file.path.toString().split("/");
    String fName = name[name.length - 1].replaceAll("'", "");
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: FaIcon(FontAwesomeIcons.shareSquare),
              onPressed: () async {
                Uint8List pfile = await widget.file.readAsBytes();
                await Share.file('Pdf Document', fName, pfile, '*/*');
              })
        ],
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Text(fName),
        centerTitle: true,
      ),
      body: Center(
        child: loading
            ? loadingCircle()
            : Container(
                // color: Color.fromRGBO(58, 66, 86, 1.0),
                // child: p.PDFView(
                //   filePath: widget.file.path,
                // ),
                child: PDFViewer(
                  document: doc,
                  scrollDirection: Axis.horizontal,
                  enableSwipeNavigation: true,
                  progressIndicator: loadingCircle(),
                  pickerButtonColor: Color.fromRGBO(58, 66, 86, 1.0),
                  showNavigation: true,
                ),
              ),
      ),
    );
  }
}
