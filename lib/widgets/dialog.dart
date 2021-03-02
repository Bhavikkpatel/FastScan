import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/pages/Index.dart';
import 'package:scanner/widgets/contants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as io;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class CusDialog extends StatefulWidget {
  PdfDocument pdf;
  CusDialog(this.pdf);
  ValueChanged<String> onChanged, onSubmitted;
  @override
  _CusDialogState createState() => _CusDialogState();
}

class _CusDialogState extends State<CusDialog> {
  Future start() async {
    var dir = await getExternalStorageDirectory();
    await new io.Directory('${dir.path}/Scan').create(recursive: true);
  }

  bool isSameName = false;
  bool noName = false;
  List file = new List();
  String directory;
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

  Duration duration = const Duration(milliseconds: 500);
  TextEditingController fileName = TextEditingController();
  bool isShadow = true;
  @override
  initState() {
    get();
    super.initState();
  }

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
          height: MediaQuery.of(context).size.height * 0.43,
          padding: EdgeInsets.only(
            left: Constants.padding,
            top: Constants.avatarRadius + Constants.padding,
            right: Constants.padding,
          ),
          // bottom: Constants.padding
          margin: EdgeInsets.only(top: Constants.avatarRadius - 30),
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
                'Save Pdf',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Enter file name',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              AnimatedContainer(
                width: double.maxFinite,
                height: 50,
                margin: const EdgeInsets.all(10),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                    boxShadow: isShadow
                        ? [
                            BoxShadow(
                                color: Colors.grey,
                                blurRadius: 2,
                                spreadRadius: 1)
                          ]
                        : BoxShadow(spreadRadius: 0, blurRadius: 0),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: const Color(0xff111823)),
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.only(right: 50, top: 3),
                              child: TextField(
                                cursorWidth: 2,
                                style: TextStyle(
                                  fontSize: 15,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                                autofocus: true,
                                controller: fileName,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 17),
                                    hintStyle: TextStyle(
                                        color: const Color(0xff5c5bb0)),
                                    hintText: 'Enter File Name',
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                duration: duration,
              ),
              SizedBox(
                height: 5,
              ),
              (isSameName == true)
                  ? Align(
                      alignment: Alignment.center,
                      child:
                          Text('file with name ${fileName.text} already exist'),
                    )
                  : noName == true
                      ? Align(
                          alignment: Alignment.center,
                          child: Text('file with name cannot be empty'),
                        )
                      : Container(),
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          width: 1,
                          color: const Color(0xff5c5bb0),
                        )),
                    onPressed: () async {
                      List<dynamic> fNameList = [];
                      for (dynamic a in file) {
                        fNameList.add(a
                            .toString()
                            .split('/')
                            .last
                            .replaceAll("'", "")
                            .split('.')
                            .first);
                      }
                      if (!fNameList.contains(fileName.text)) {
                        if (fileName.text != '') {
                          await start();
                          io.Directory documentDirectory =
                              await getApplicationDocumentsDirectory();
                          String documentPath = documentDirectory.path;
                          io.File file = new io.File(
                              "$documentPath/scan/${fileName.text}.pdf");
                          print('${file.path}');
                          file.writeAsBytes(widget.pdf.save());
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          pref.setBool('check', false);
                          print(pref.getBool('check'));
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Index()));
                        } else {
                          setState(() {
                            isSameName = false;
                            noName = true;
                          });
                        }
                      } else {
                        setState(() {
                          noName = false;
                          isSameName = true;
                        });
                      }
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(fontSize: 18),
                    )),
              ),
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
