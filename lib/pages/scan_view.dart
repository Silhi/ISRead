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
  List<BukuModel> buku = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final String jsonResponse =
          await ds.selectAll(token, project, 'buku', appid);
      final List data = jsonDecode(jsonResponse);
      buku = data.map((e) => BukuModel.fromJson(e)).toList();
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
      // Cari buku berdasarkan barcode (ID)
      final BukuModel? scannedBook =
          buku.firstWhere((book) => book.id == barcode);

      if (scannedBook != null) {
        // Jika ditemukan, arahkan ke halaman detail buku
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(bookId: scannedBook.id),
          ),
        );
      } else {
        // Jika tidak ditemukan, tampilkan pop-up
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Buku Tidak Terdaftar'),
            content: const Text(
                'Buku dengan barcode ini tidak ditemukan di database.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
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
      backgroundColor: Colors.white,
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
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleBarcode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
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
