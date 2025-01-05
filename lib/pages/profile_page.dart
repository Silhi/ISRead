import 'dart:convert';
import 'dart:async';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:isread/pages/welcome_page.dart';
import 'package:isread/models/user_model.dart';
import 'package:isread/models/book_model.dart';
import 'package:isread/models/loan_model.dart';
import 'package:isread/models/return_model.dart';
import 'package:isread/utils/fire_auth.dart';

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
  List<UserModel> user = [];
  List<BukuModel> buku = [];
  List<PeminjamanModel> peminjaman = [];

  List userData = [];
  List bukuData = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    loadData();
  }

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

  Future<void> loadData() async {
    try {
      // Log untuk melacak permintaan data user
      debugPrint('Mengambil data user untuk: ${currentUser!.id}');
      final userResponse =
          await ds.selectId(token, project, 'user', appid, currentUser!.id);
      debugPrint('Respons user: $userResponse');
      currentUser = UserModel.fromJson(jsonDecode(userResponse));
      user = currentUser != null
          ? [currentUser!]
          : userData
              .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList();

      // Log untuk melacak permintaan data peminjaman
      debugPrint('Mengambil data peminjaman untuk: ${currentUser!.id}');
      final peminjamanResponse = await ds.selectWhere(
          token, project, 'peminjaman', appid, 'id_user', currentUser!.id);
      debugPrint('Respons peminjaman: $peminjamanResponse');
      final peminjamanData = jsonDecode(peminjamanResponse) as List<dynamic>;
      peminjaman = peminjamanData
          .map((e) => PeminjamanModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Log untuk melacak data buku
      buku = [];
      for (var peminjamanItem in peminjaman) {
        debugPrint('Mengambil data buku untuk ID: ${peminjamanItem.id_buku}');
        final bukuResponse = await ds.selectWhere(
          token,
          project,
          'buku',
          appid,
          '_id',
          peminjamanItem.id_buku,
        );
        debugPrint(
            'Respons buku untuk ID ${peminjamanItem.id_buku}: $bukuResponse');
        final bukuList = jsonDecode(bukuResponse) is Map<String, dynamic>
            ? [jsonDecode(bukuResponse)]
            : jsonDecode(bukuResponse) as List<dynamic>;
        buku.addAll(
          bukuList
              .map((e) => BukuModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }

      // Selesai memuat data
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
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back, size: 24),
                      ),
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
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        'login_page', // Rute halaman Login
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
                  backgroundImage:
                      profpic.isNotEmpty ? NetworkImage(profpic) : null,
                  radius: 50,
                ),
                ElevatedButton(
                  onPressed: () => pickImage(currentUser!.id),
                  child: Text('Upload Foto Profil'),
                ),
                SizedBox(height: 16),
                if (user.isNotEmpty) ...[
                  Text(user[0].username,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(user[0].email, style: TextStyle(color: Colors.black)),
                  SizedBox(height: 5),
                  Text(user[0].no_telpon,
                      style: TextStyle(color: Colors.black)),
                  SizedBox(height: 5),
                ],
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      user.isNotEmpty ? () => pickImage(user[0].nrp) : null,
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
                                var sudahDikembalikan =
                                    peminjamanItem.status == 'Selesai';
                                var bukuItem = buku.firstWhere(
                                    (b) => b.id == peminjamanItem.id_buku,
                                    orElse: () => BukuModel(
                                        id: '',
                                        judul_buku: 'Tidak Ditemukan',
                                        pengarang: '',
                                        penerbit: '',
                                        kategori_buku: '',
                                        tahun_terbit: '',
                                        sampul_buku: '',
                                        status: '',
                                        deskripsi: '',
                                        dosen_pembimbing: '',
                                        kode_buku: ''));

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
                                        'Status: ${peminjamanItem.status}',
                                        style: TextStyle(
                                            color: sudahDikembalikan
                                                ? Colors.red
                                                : Colors.black,
                                            fontSize: 12),
                                      ),
                                      if (!sudahDikembalikan)
                                        Text(
                                          terlambat > 0
                                              ? 'Anda telat $terlambat hari'
                                              : '',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Spacer(), // tombol di sisi kanan
                                          Positioned(
                                            right: 16,
                                            top: 100,
                                            child: ElevatedButton(
                                              onPressed: sudahDikembalikan
                                                  ? null
                                                  : () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        'form_kembali',
                                                        arguments: [
                                                          peminjamanItem.id,
                                                          user[0].nrp
                                                        ],
                                                      );
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    sudahDikembalikan
                                                        ? Colors.grey
                                                        : (terlambat > 0
                                                            ? Colors.red
                                                            : Colors.blue),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8),
                                              ),
                                              child: Text(
                                                sudahDikembalikan
                                                    ? 'Selesai'
                                                    : 'Kembalikan',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
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
