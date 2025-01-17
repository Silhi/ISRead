import 'dart:convert';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:isread/models/book_model.dart';
import 'package:isread/models/user_model.dart';
import 'package:isread/models/loan_model.dart';
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
    // Validasi apakah buktiFoto sudah diunggah
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Harap unggah foto bukti pengembalian terlebih dahulu.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return; // Menghentikan eksekusi jika belum ada foto
    }

    try {
      String buktiFoto = base64Encode(File(_imagePath!).readAsBytesSync());
      String tglDikembalikan = DateFormat('dd-MM-yyyy').format(tanggalKembali!);

      await ds.insertPengembalian(
        appid,
        widget.peminjamanId,
        tglDikembalikan,
        buktiFoto,
      );

      await updateBookStatus(widget.bookId);
      await updateLoanStatus(widget.peminjamanId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pengembalian berhasil!",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
        ),
      );
    }
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
                // Header
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
                // Cover Image
                if (buku == null)
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 150,
                      height: 200,
                      color: Colors.grey,
                    ),
                  )
                else
                  Container(
                    width: 150,
                    height: 200,
                    child: Image.asset(
                      "assets/sampul/${buku!.kategori_buku}.jpeg",
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 10),
                // Book Details
                if (buku == null)
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      children: [
                        Container(
                          width: 200,
                          height: 20,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: 150,
                          height: 15,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: 100,
                          height: 15,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  )
                else ...[
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
                // Date Section
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
                      if (tanggalKembali == null)
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 100,
                            height: 20,
                            color: Colors.grey,
                          ),
                        )
                      else
                        Text(
                          DateFormat('d MMMM yyyy').format(tanggalKembali!),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Photo Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bukti Foto',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
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
                SizedBox(height: 20),
                // Button
                ElevatedButton(
                  onPressed: _handlePengembalian,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Unggah',
                    style: TextStyle(fontSize: 16),
                  ),
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
//baru