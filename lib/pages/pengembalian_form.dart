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

  Future<void> _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path; // Menyimpan path gambar
      });
    }
  }

  Future<void> _handlePengembalian() async {
    // if (_imagePath == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text("Harap ambil foto bukti pengembalian terlebih dahulu."),
    //     ),
    //   );
    //   return;
    // }

    // try {

    String? buktiFoto;
    if (_imagePath != null) {
      buktiFoto = base64Encode(File(_imagePath!).readAsBytesSync());
    } else {
      buktiFoto = null; // Atur buktiFoto menjadi null jika tidak ada foto
    }

    String tglDikembalikan = DateFormat('dd-MM-yyyy').format(
        tanggalKembali!); // Ambil tanggal dikembalikan dalam format string

    await ds.insertPengembalian(
      appid, // Gunakan appid yang relevan
      widget.peminjamanId,
      tglDikembalikan,
      buktiFoto ?? "",
    );

    print("Pengembalian berhasil disimpan.");

    await updateBookStatus(widget.bookId);
    print("Status buku diperbarui.");

    await updateLoanStatus(widget.peminjamanId);
    print("Status peminjaman diperbarui.");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Pengembalian berhasil!"),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text("Terjadi kesalahan: $e"),
    //     ),
    //   );
    // }
  }

  Future<void> updateBookStatus(String whereValue) async {
    print("Mengupdate status buku untuk ID: $whereValue");
    try {
      await ds.updateId(
          'status', 'Tersedia', token, project, 'buku', appid, whereValue);
      print("Berhasil mengupdate status buku.");
    } catch (e) {
      print("Gagal mengupdate status buku: $e");
    }
  }

  Future<void> updateLoanStatus(String whereValue) async {
    print("Mengupdate status peminjaman untuk ID: $whereValue");
    try {
      await ds.updateId(
          'status', 'Selesai', token, project, 'peminjaman', appid, whereValue);
      print("Berhasil mengupdate status peminjaman.");
    } catch (e) {
      print("Gagal mengupdate status peminjaman: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 30),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  width: 150,
                  height: 200,
                  color: Colors.grey[300],
                  child: Image.asset(
                    "assets/sampul/${buku!.kategori_buku ?? 'default'}.jpeg",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.my_library_books_rounded,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tanggal Kembali',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 22),
                      SizedBox(width: 10),
                      Text(
                        DateFormat('d MMMM yyyy').format(tanggalKembali!),
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bukti Foto',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  child: GestureDetector(
                    onTap: _openCamera,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[300],
                      child: _imagePath == null
                          ? const Icon(Icons.camera_alt, size: 50)
                          : Image.file(File(_imagePath!)),
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
                if (_imagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Image.file(File(_imagePath!)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//running program
//flutter run --web-renderer html
