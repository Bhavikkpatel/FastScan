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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          child: Icon(Icons.save_outlined),
        ),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          title: Text('re-arrange'),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(
                  LineIcons.save,
                  size: 30,
                ),
                onPressed: () {
                  PdfDocument pdf = PdfDocument();
                  for (int i = 0; i < widget.image.length; i++) {
                    // print(img[i]);
                    PdfPage page = pdf.pages.add();
                    page.graphics.drawImage(
                        PdfBitmap(img[i]),
                        Rect.fromLTWH(0, 0, page.getClientSize().width,
                            page.getClientSize().height));
                  }
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CusDialog(pdf);
                      });
                }),
            IconButton(
                icon: Icon(
                  LineIcons.windowClose,
                  size: 30,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DiscardDialog();
                      });
                })
          ],
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
