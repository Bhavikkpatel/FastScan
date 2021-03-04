import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:scanner/pages/image_adjust.dart';
import 'package:scanner/widgets/contants.dart';
import 'dart:io' as io;

class ImgsrcDialog extends StatefulWidget {
  @override
  _ImgsrcDialogState createState() => _ImgsrcDialogState();
}

class _ImgsrcDialogState extends State<ImgsrcDialog> {
  Duration duration = const Duration(milliseconds: 500);
  bool isShadow = true;
  @override
  initState() {
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

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width * 0.5,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          // bottom: Constants.padding
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.06,
              left: MediaQuery.of(context).size.width * 0.085),
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
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03),
                child: OutlineButton(
                  highlightedBorderColor: Color.fromRGBO(58, 66, 86, 1.0),
                  highlightElevation: 10,
                  borderSide: BorderSide(width: 2),
                  onPressed: () {
                    _getImage(ImageSource.camera);
                  },
                  child: Text('Camera'),
                ),
              ),
              OutlineButton(
                highlightedBorderColor: Color.fromRGBO(58, 66, 86, 1.0),
                highlightElevation: 10,
                borderSide: BorderSide(width: 2),
                onPressed: () {
                  _getImage(ImageSource.gallery);
                },
                child: Text('Gallery'),
              ),
            ],
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.1,
          right: MediaQuery.of(context).size.width * 0.1,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.all(Radius.circular(Constants.avatarRadius)),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    LineIcons.image,
                    color: Color.fromRGBO(58, 66, 86, 1.0),
                    size: MediaQuery.of(context).size.height * 0.05,
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
