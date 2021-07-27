import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 400,
            width: 400,
            child: RepaintBoundary(
              key: _globalKey,
              child: SafeArea(child: SfDateRangePicker()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ElevatedButton(
              onPressed: _renderPickerPDF,
              child: Text('Picker to pdf'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _renderPickerPDF() async {
    PdfDocument document = PdfDocument();
    PdfPage page = document.pages.add();
    final RenderRepaintBoundary boundary =
        _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    final ui.Image data = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? bytes =
        await data.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageBytes =
        bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    page.graphics
        .drawImage(PdfBitmap(imageBytes), Rect.fromLTWH(25, 50, 300, 300));
    List<int> byteData = document.save();
    document.dispose();
    Directory? directory = await getExternalStorageDirectory();
    String path = directory!.path;
    print(path.toString() + ' Path');
    File file = File('$path/Output.pdf');
    await file.writeAsBytes(byteData, flush: true);
    OpenFile.open('$path/Output.pdf');
  }
}
