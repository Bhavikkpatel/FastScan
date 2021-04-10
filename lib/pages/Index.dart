import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanner/pages/Home.dart';
import 'package:scanner/pages/image_adjust.dart';
import './camera.dart';
import './profile.dart';
import 'dart:io' as io;

class Index extends StatefulWidget {
  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool isappBar = true;
  List<Widget> pages = [
    ImageCapture(),
    Profile(),
  ];
  var currentindex = 0;

  @override
  void initState() {
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: isappBar
        //     ? AppBar(
        //         backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        //         centerTitle: true,
        //         title: Text('Your Documents'),
        //         automaticallyImplyLeading: false,
        //       )
        //     : null,
        // bottomNavigationBar: BottomNavigationBar(
        //   backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        //   selectedItemColor: Colors.white,
        //   items: [
        //     BottomNavigationBarItem(
        //       icon: Icon(
        //         Icons.scanner,
        //       ),
        //       label: 'Scanner',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.person),
        //       label: 'Profile',
        //     ),
        //   ],
        //   currentIndex: currentindex,
        //   onTap: (index) {
        //     setState(() {
        //       currentindex = index;
        //       if (index == 1) {
        //         isappBar = false;
        //       } else {
        //         isappBar = true;
        //       }
        //     });
        //   },
        // ),
        body: Home(),
        // body: ImageCapture(),
      ),
    );
  }
}
