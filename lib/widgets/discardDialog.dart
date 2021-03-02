import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/pages/Index.dart';
import 'package:scanner/widgets/contants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as io;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DiscardDialog extends StatefulWidget {
  @override
  _DiscardDialogState createState() => _DiscardDialogState();
}

class _DiscardDialogState extends State<DiscardDialog> {
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
                'Discard PDF',
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
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            pref.setBool('check', false);
                            while (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            'Discard',
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
