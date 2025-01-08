import 'dart:convert';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:isread/models/book_model.dart';
import 'package:isread/models/user_model.dart';
import 'package:isread/models/loan_model.dart';
import 'package:isread/models/return_model.dart';
import 'package:isread/pages/profile_page.dart';

class PengembalianPage extends StatefulWidget {
  final String peminjamanId;
  final String bookId;

  const PengembalianPage(
      {Key? key, required this.peminjamanId, required this.bookId})
      : super(key: key);

  @override
  _PengembalianPageState createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  DataService ds = DataService();
  UserModel? currentUser;
  BukuModel? buku;
  PeminjamanModel? peminjaman;

  List data = [];

  String? _imagePath;

  DateTime? tanggalKembali = DateTime.now();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    _loadPeminjaman();
    _loadBooks();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    if (userData != null && userData.isNotEmpty) {
      setState(() {
        currentUser = UserModel.fromJson(jsonDecode(userData));
      });
    }
  }

  Future<void> _loadPeminjaman() async {
    data = jsonDecode(await ds.selectId(
        token, project, 'peminjaman', appid, widget.peminjamanId));
    peminjaman = PeminjamanModel.fromJson(data[0]);
    if (peminjaman != null) {
      data = jsonDecode(await ds.selectId(
          token, project, 'buku', appid, peminjaman!.id_buku));
      buku = BukuModel.fromJson(data[0]);
    }
    setState(() {});
  }

  Future<void> _loadBooks() async {
    data = jsonDecode(await ds.selectWhere(
        token, project, 'buku', appid, '_id', peminjaman!.id_buku));
    buku = BukuModel.fromJson(data[0]);
  }

  Future<void> updateBookStatus(String whereValue) async {
    await ds.updateId(
        'status', 'Tersedia', token, project, 'buku', appid, whereValue);
  }

  Future<void> updateLoanStatus(String whereValue) async {
    await ds.updateId(
        'status', 'Selesai', token, project, 'peminjaman', appid, whereValue);
  }

  Future<void> _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      // Lakukan sesuatu dengan gambar yang diambil, misalnya menampilkan gambar tersebut
      setState(() {
        // Misalnya kita menyimpan path gambar
        _imagePath = image.path;
      });
    }
  }

  Future<void> _handlePengembalian() async {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Harap ambil foto bukti pengembalian terlebih dahulu."),
        ),
      );
      return;
    }

    try {
      await updateBookStatus(widget.bookId);
      await updateLoanStatus(widget.peminjamanId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pengembalian berhasil!"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, size: 30),
                  ),
                  Text(
                    'Pengembalian',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 30), // Placeholder for alignment
                ],
              ),
              SizedBox(height: 20),
              Container(
                width: 150,
                height: 200,
                color: Colors.grey[300],
              ),
              SizedBox(height: 10),
              if (buku != null) ...[
                Text(
                  buku!.judul_buku,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  buku!.pengarang,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  buku!.kategori_buku,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
              SizedBox(height: 20),
              // SizedBox(height: 20),
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: Text(
              //     peminjaman[0].tgl_kembali,
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //   ),
              // ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 30),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bukti Foto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 150,
                color: Colors.grey[300],
                child: GestureDetector(
                  onTap:
                      _openCamera, // Memanggil fungsi _openCamera saat container diklik
                  child: Center(
                    child: Icon(Icons.camera_alt, size: 50),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handlePengembalian,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Center(
                  child: Text(
                    'Unggah',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
              // Menampilkan gambar yang diambil
              if (_imagePath != null) Image.file(File(_imagePath!)),
            ],
          ),
        ),
      ),
    );
  }
}
