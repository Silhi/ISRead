import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:isread/models/loan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:isread/models/book_model.dart';
import 'package:isread/models/user_model.dart';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';

class PeminjamanPage extends StatefulWidget {
  final String bookId;
  final Map<String, dynamic>? userData;

  const PeminjamanPage({Key? key, required this.bookId, required this.userData})
      : super(key: key);

  @override
  _PeminjamanPageState createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  DataService ds = DataService();
  UserModel? currentUser;
  BukuModel? buku;
  List data = [];

  DateTime? tanggalPinjam = DateTime.now();
  DateTime? tanggalKembali;

  TextEditingController tanggalKembaliController = TextEditingController();

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    if (userData != null && userData.isNotEmpty) {
      setState(() {
        currentUser = UserModel.fromJson(jsonDecode(userData));
      });
    }
  }

  Future<void> fetchBookDetails() async {
    data = jsonDecode(
        await ds.selectId(token, project, 'buku', appid, widget.bookId));
    buku = BukuModel.fromJson(data[0]);
    setState(() {});
  }

  Future<void> updateBookStatus(String whereValue) async {
    await ds.updateId(
        'status', 'Tidak Tersedia', token, project, 'buku', appid, whereValue);
  }

  Future<void> selectTanggalKembali(BuildContext context) async {
    DateTime lastDate = DateTime.now().add(Duration(
      days: buku?.kategori_buku == "Umum" ? 7 : 3,
    ));

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: lastDate,
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Theme.of(context).colorScheme.primary,
              colorScheme: ColorScheme.light(
                  primary: Theme.of(context).colorScheme.surface),
              buttonTheme:
                  const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        });

    if (picked != null) {
      setState(() {
        tanggalKembali = picked;
        tanggalKembaliController.text =
            DateFormat('dd-MM-yyyy').format(tanggalKembali!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    fetchBookDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Peminjaman Buku',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: buku == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 172,
                        height: 225,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: buku?.sampul_buku == "-" ||
                                  buku?.sampul_buku == null
                              ? Colors.grey[300]
                              : null,
                          image: buku?.sampul_buku != "-" &&
                                  buku?.sampul_buku != null
                              ? DecorationImage(
                                  image: NetworkImage(buku?.sampul_buku ??
                                      "assets/sampul/${buku?.kategori_buku}.jpeg"),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: buku?.sampul_buku == "-" ||
                                buku?.sampul_buku == null
                            ? const Icon(
                                Icons.book,
                                color: Colors.grey,
                                size: 40,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        buku?.judul_buku ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        buku?.pengarang ?? 'Unknown Author',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        buku?.kategori_buku ?? 'Uknown Category',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildReadOnlyTextField(
                      label: 'Nama Peminjam',
                      value: currentUser?.username ?? 'Tidak Diketahui',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyTextField(
                      label: 'Nomor Telepon',
                      value: currentUser?.no_telpon ?? 'Tidak Diketahui',
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyTextField(
                      label: 'Tanggal Pinjam',
                      value: DateFormat('dd-MM-yyyy').format(tanggalPinjam!),
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => selectTanggalKembali(context),
                      child: AbsorbPointer(
                        child: _buildReadOnlyTextField(
                          label: 'Tanggal Kembali',
                          value: tanggalKembaliController.text.isNotEmpty
                              ? tanggalKembaliController.text
                              : "Pilih Tanggal Kembali",
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (tanggalKembali != null &&
                              currentUser != null &&
                              buku != null) {
                            List response = jsonDecode(
                                await ds.insertPeminjaman(
                                    appid,
                                    buku?.id ?? "Undefined",
                                    currentUser?.id ?? "Undefined",
                                    DateFormat('dd-MM-yyyy')
                                        .format(tanggalPinjam!),
                                    DateFormat('dd-MM-yyyy')
                                        .format(tanggalKembali!),
                                    "0",
                                    "Berlangsung",
                                    buku?.judul_buku ?? "Undefined"));

                            List<PeminjamanModel> dataPinjam = response
                                .map((e) => PeminjamanModel.fromJson(e))
                                .toList();

                            if (dataPinjam.length == 1) {
                              updateBookStatus(buku?.id ?? "Undefined");
                              Navigator.pushReplacementNamed(
                                  context, 'home_page');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                      "Peminjaman berhasil hingga ${DateFormat('dd-MM-yyyy').format(tanggalKembali!)} oleh ${currentUser?.email}!",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface),
                              );
                            } else {
                              if (kDebugMode) {
                                print(response);
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Lengkapi semua data terlebih dahulu!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Konfirmasi Peminjaman',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }

  Widget _buildReadOnlyTextField({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return TextFormField(
      controller:
          TextEditingController.fromValue(TextEditingValue(text: value)),
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
      ),
    );
  }
}
