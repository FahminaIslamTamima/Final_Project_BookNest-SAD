
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfReaderPage extends StatelessWidget {
  const PdfReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wuthering Heights'),
        centerTitle: true,
      ),

      body: SfPdfViewer.asset(
        'assets/pdfs/wuthering_heights.pdf',
      ),
    );
  }
}
 