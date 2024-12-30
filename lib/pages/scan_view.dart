import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';

import 'package:isread/models/book_model.dart';
import 'package:isread/pages/book_detail_screen.dart';
import 'package:isread/utils/config.dart';
import 'package:isread/utils/restapi.dart';

class ScanView extends StatefulWidget {
  const ScanView({Key? key}) : super(key: key);

  @override
  _ScanViewState createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  DataService ds = DataService();
  List data = [];
  List<BukuModel> buku = [];
  List<BukuModel> filteredBuku = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      data = jsonDecode(await ds.selectAll(token, project, 'buku', appid));
      buku = data.map((e) => BukuModel.fromJson(e)).toList();
      setState(() {
        buku = buku;
      });
    } catch (e) {
      print("Error loading books: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load books.')),
      );
    }
  }

  Future<void> _handleBarcode(String barcode) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final BukuModel? scannedBook =
          buku.firstWhere((book) => book.kode_buku == barcode);

      if (scannedBook != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(bookId: scannedBook.id),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book not found in the database.')),
        );
      }
    } catch (e) {
      print("Error handling barcode: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error occurred while scanning.')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Barcode scanner
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleBarcode(barcode.rawValue!);
                  break; // Stop after handling the first barcode
                }
              }
            },
          ),

          // Flashlight toggle button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              height: 60,
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.flash_on,
                    size: 30,
                  ),
                  onPressed: () {
                    _controller.toggleTorch();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
