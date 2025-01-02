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
  int _selectedIndex = 2;
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
        title: const Text(
          'Scan Barcode',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Center(
            child: ClipRect(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 300,
                  height: 100,
                  child: MobileScanner(
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
                ),
              ),
            ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              if (ModalRoute.of(context)?.settings.name != 'home_page') {
                Navigator.pushReplacementNamed(context, 'home_page');
              }
              break;
            case 1:
              if (ModalRoute.of(context)?.settings.name != 'book_page') {
                Navigator.pushReplacementNamed(context, 'book_page');
              }
              break;
            case 2:
              if (ModalRoute.of(context)?.settings.name != 'scan_page') {
                Navigator.pushReplacementNamed(context, 'scan_page');
              }
              break;
            case 3:
              if (ModalRoute.of(context)?.settings.name != 'profile_page') {
                Navigator.pushReplacementNamed(context, 'profile_page');
              }
              break;
          }
        },
        backgroundColor: const Color(0xff112D4E),
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xffDBE2EF),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
