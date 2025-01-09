import 'dart:convert';
import 'dart:async';
import 'package:isread/pages/pengembalian_form.dart';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:isread/utils/fire_auth.dart';
import 'package:isread/pages/welcome_page.dart';
import 'package:isread/models/user_model.dart';
import 'package:isread/models/book_model.dart';
import 'package:isread/models/loan_model.dart';
import 'package:isread/models/return_model.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfilePage({Key? key, this.userData}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DataService ds = DataService();
  int _selectedIndex = 3;
  UserModel? currentUser;
  String profpic = '';

  List<PeminjamanModel> peminjaman = [];

  // List bukuData = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initUserAndLoadData();
  }

  Future<void> initUserAndLoadData() async {
    await checkLoginStatus();
    if (currentUser != null) {
      await loadData();
    }
  }

  //Mengelola data user yang login
  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    if (userData != null && userData.isNotEmpty) {
      setState(() {
        currentUser =
            UserModel.fromJson(jsonDecode(userData)); // Menyimpan data pengguna
      });
    }
  }

  //Mengambil data peminjaman dan buku
  Future<void> loadData() async {
    try {
      final peminjamanResponse = await ds.selectWhere(
          token!, project!, 'peminjaman', appid!, 'id_user', currentUser!.id);

      final peminjamanData = jsonDecode(peminjamanResponse) as List<dynamic>;
      peminjaman = peminjamanData
          .map((e) => PeminjamanModel.fromJson(e as Map<String, dynamic>))
          .toList();

      for (var peminjamanItem in peminjaman) {
        final DateTime tanggalPinjam =
            DateTime.parse(peminjamanItem.tgl_pinjam);
        final DateTime batasPengembalian = tanggalPinjam.add(Duration(days: 7));
        final DateTime sekarang = DateTime.now();
        final int terlambat = sekarang.isAfter(batasPengembalian)
            ? sekarang.difference(batasPengembalian).inDays
            : 0;

        final int denda = terlambat * 500;
        if (peminjamanItem.denda != denda.toString()) {
          await ds.updateId(
            'denda',
            denda.toString(),
            token,
            project,
            'peminjaman',
            appid,
            peminjamanItem.id,
          );
        }
      }

      setState(() {
        isLoading = false;
      });
      debugPrint('Data berhasil dimuat.');
    } catch (error) {
      debugPrint('Error loading data: $error');
    }
  }

  //Foto Profil
  Future<void> pickImage(String id) async {
    try {
      final picked = await FilePicker.platform.pickFiles(withData: true);
      if (picked != null) {
        final response = await ds.upload(
          token,
          project,
          picked.files.first.bytes!,
          picked.files.first.extension.toString(),
        );
        final file = jsonDecode(response);
        await ds.updateId(
            'profpic', file['file_name'], token, project, 'user', appid, id);
        setState(() {
          profpic = file['file_name'];
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Profil
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 5,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Profile',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Konfirmasi Logout',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                    textAlign: TextAlign.center),
                                content: Text(
                                    'Apakah Anda yakin ingin keluar dari akun?',
                                    style: TextStyle(color: Colors.white)),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.remove(
                                          'userData'); // Menghapus data login user
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        'welcome_screen',
                                        (route) => false,
                                      );
                                    },
                                    child: Text('Logout'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(Icons.power_settings_new, size: 24),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundImage: profpic.isNotEmpty
                      ? NetworkImage(profpic)
                      : AssetImage("assets/avatar/dummy.jpg") as ImageProvider,
                  radius: 50,
                ),
                SizedBox(height: 16),
                if (currentUser != null) ...[
                  Text(currentUser!.username,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(currentUser!.email,
                      style: TextStyle(color: Colors.black)),
                  SizedBox(height: 5),
                  Text(currentUser!.no_telpon,
                      style: TextStyle(color: Colors.black)),
                  SizedBox(height: 5),
                ],
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: currentUser != null
                      ? () => pickImage(currentUser!.id)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text('Edit Profile', style: TextStyle(fontSize: 12)),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),

          // Riwayat Peminjaman
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 5,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text('Riwayat Peminjaman',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              itemCount: peminjaman.length,
                              itemBuilder: (context, index) {
                                var peminjamanItem = peminjaman[index];
                                var tanggalPinjam =
                                    DateTime.parse(peminjamanItem.tgl_pinjam);
                                var batasPengembalian =
                                    tanggalPinjam.add(Duration(days: 7));
                                var sekarang = DateTime.now();
                                var terlambat =
                                    sekarang.isAfter(batasPengembalian)
                                        ? sekarang
                                            .difference(batasPengembalian)
                                            .inDays
                                        : 0;
                                var statusSelesai =
                                    peminjamanItem.status == 'Selesai';

                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(peminjamanItem.judul_buku,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                        'Tanggal Kembali: ${DateFormat('d MMMM yyyy').format(batasPengembalian)}',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                      Text(
                                          'Peminjaman ID : ${peminjamanItem.id}',
                                          style: TextStyle(
                                            fontSize: 12,
                                          )),
                                      Text(
                                          'Buku ID : ${peminjamanItem.id_buku}',
                                          style: TextStyle(
                                            fontSize: 12,
                                          )),
                                      Text(
                                        'Status: ${peminjamanItem.status}',
                                        style: TextStyle(
                                            color: statusSelesai
                                                ? Colors.red
                                                : Colors.black,
                                            fontSize: 12),
                                      ),
                                      if (!statusSelesai && terlambat > 0)
                                        Text(
                                          'Anda telat $terlambat hari',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      if (!statusSelesai && terlambat > 0)
                                        Text(
                                          'Denda: Rp ${terlambat * 500}',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Spacer(),
                                          ElevatedButton(
                                            onPressed: statusSelesai
                                                ? null
                                                : () {
                                                    if (peminjamanItem !=
                                                            null &&
                                                        peminjamanItem.id !=
                                                            null) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              PengembalianPage(
                                                            peminjamanId:
                                                                peminjamanItem
                                                                    .id!,
                                                            bookId:
                                                                peminjamanItem
                                                                    .id_buku!,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Data peminjaman atau buku tidak valid.'),
                                                        ),
                                                      );
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: statusSelesai
                                                  ? Colors.grey
                                                  : (terlambat > 0
                                                      ? Colors.red
                                                      : Colors.blue),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 8),
                                            ),
                                            child: Text(
                                              statusSelesai
                                                  ? 'Selesai'
                                                  : 'Kembalikan',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
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
                Navigator.pushReplacementNamed(
                  context,
                  'home_page',
                );
              }
              break;
            case 1: // For Books
              if (ModalRoute.of(context)?.settings.name != 'book_page') {
                Navigator.pushReplacementNamed(
                  context,
                  'book_page',
                );
              }
              break;
            case 2:
              if (ModalRoute.of(context)?.settings.name != 'scan_page') {
                Navigator.pushReplacementNamed(
                  context,
                  'scan_page',
                );
              }
              break;
            case 3:
              if (ModalRoute.of(context)?.settings.name != 'profile_page') {
                Navigator.pushReplacementNamed(
                  context,
                  'profile_page',
                );
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
