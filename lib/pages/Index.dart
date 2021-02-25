import 'package:flutter/material.dart';
import './camera.dart';
import './profile.dart';

class Index extends StatefulWidget {
  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  List<Widget> pages = [
    ImageCapture(),
    Profile(),
  ];
  var currentindex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        centerTitle: true,
        title: Text('Scan'),
        automaticallyImplyLeading: false,
      ),
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
      //     });
      //   },
      // ),
      // body: pages[currentindex],
      body: ImageCapture(),
    );
  }
}
