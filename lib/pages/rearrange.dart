import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:reorderables/reorderables.dart';
import 'package:scanner/widgets/dialog.dart';
import 'package:scanner/widgets/discardDialog.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class Rearrange extends StatefulWidget {
  final List<dynamic> image;
  final height;
  final width;
  Rearrange(this.image, this.height, this.width);
  @override
  _RearrangeState createState() => _RearrangeState(image);
}

class _RearrangeState extends State<Rearrange> {
  List<dynamic> img;
  _RearrangeState(this.img);
  var images = <Widget>[];
  void add() {
    print(img.length);
    for (int i = 0; i < widget.image.length; i++) {
      Widget container = Container(
        height: widget.height + 50,
        width: widget.width + 50,
        child: Image.memory(widget.image[i]),
      );
      images.add(container);
    }
  }

  @override
  void initState() {
    add();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      print('old: $oldIndex, new: $newIndex');
      setState(() {
        var temp = img[oldIndex];
        img.removeAt(oldIndex);
        img.insert(newIndex, temp);
        var t = images.removeAt(oldIndex);
        images.insert(newIndex, t);
      });
    }

    var wrap = ReorderableWrap(
        spacing: 8.0,
        runSpacing: 4.0,
        padding: EdgeInsets.all(8),
        children: images,
        onReorder: _onReorder,
        onNoReorder: (int index) {
          debugPrint(
              '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
        },
        onReorderStarted: (int index) {
          //this callback is optional
          debugPrint(
              '${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
        });

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            're-arrange',
            style: TextStyle(color: Colors.black),
          ),
          leadingWidth: MediaQuery.of(context).size.width * 0.1,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              size: 30,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [],
        ),
        body: Container(
          // color: Color.fromRGBO(58, 66, 86, 1.0),
          color: Colors.grey[300],
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  wrap,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
