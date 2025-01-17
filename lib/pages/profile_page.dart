import 'dart:convert';
import 'dart:async';
import 'package:isread/pages/pengembalian_form.dart';
import 'package:isread/pages/welcome_page.dart';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isread/models/user_model.dart';
import 'package:isread/models/book_model.dart';
import 'package:isread/models/loan_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DataService ds = DataService();
  int _selectedIndex = 3;
  UserModel? currentUser;
  BukuModel? buku;
  String profpic = '';

  List<PeminjamanModel> peminjaman = [];
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

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    if (userData != null && userData.isNotEmpty) {
      setState(() {
        currentUser = UserModel.fromJson(jsonDecode(userData));
      });
    }
  }

  // Mengambil data peminjaman dan buku
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

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: currentUser == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Anda Belum Login!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WelcomeScreen(),
                          ),
                        );
                      },
                      child: const Text('Login Sekarang'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: media.width * 0,
                    ),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Profile',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Konfirmasi Logout',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                          content: Text(
                                            'Apakah Anda yakin ingin keluar dari akun?',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
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
                                                    await SharedPreferences
                                                        .getInstance();
                                                await prefs.remove('userData');
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
                                  child:
                                      Icon(Icons.power_settings_new, size: 24),
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            backgroundImage: currentUser!.profpic.isNotEmpty
                                ? NetworkImage(fileUri + currentUser!.profpic)
                                : null,
                            radius: 50,
                            child: currentUser!.profpic.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.blueGrey,
                                  )
                                : null,
                          ),
                          SizedBox(height: 16),
                          if (currentUser != null) ...[
                            Text(currentUser!.username,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
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
                                ? () => showEditProfileForm(
                                      context,
                                      currentUser,
                                      () {
                                        initUserAndLoadData();
                                      },
                                    )
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                            ),
                            child: Text('Edit Profile',
                                style: TextStyle(fontSize: 12)),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Container(
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
                              child: Text(
                                'Riwayat Peminjaman',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 16),
                            if (isLoading)
                              Center(child: CircularProgressIndicator())
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
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
                                        Text(
                                          peminjamanItem.judul_buku,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Tanggal Kembali: ${DateFormat('d MMMM yyyy').format(batasPengembalian)}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12),
                                        ),
                                        if (!statusSelesai && terlambat > 0)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Anda telat $terlambat hari',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                'Denda: Rp ${terlambat * 500}',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Spacer(),
                                            ElevatedButton(
                                              onPressed: statusSelesai
                                                  ? null
                                                  : () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              PengembalianPage(
                                                            peminjamanId:
                                                                peminjamanItem
                                                                    .id,
                                                            bookId:
                                                                peminjamanItem
                                                                    .id_buku,
                                                          ),
                                                        ),
                                                      );
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
                                                    horizontal: 16,
                                                    vertical: 8),
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
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

// Tambahkan form edit user profile dalam bentuk pop up
// Tambahkan form edit user profile dalam bentuk pop up
void showEditProfileForm(
    BuildContext context, UserModel? currentUser, Function onUpdate) {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController =
      TextEditingController(text: currentUser?.username);
  TextEditingController emailController =
      TextEditingController(text: currentUser?.email);
  TextEditingController phoneController =
      TextEditingController(text: currentUser?.no_telpon);
  String? updatedProfpic;

  Future<void> pickImage() async {
    try {
      final picked = await FilePicker.platform.pickFiles(withData: true);
      if (picked != null) {
        final response = await DataService().upload(
          token,
          project,
          picked.files.first.bytes!,
          picked.files.first.extension.toString(),
        );
        final file = jsonDecode(response);
        updatedProfpic = file['file_name'];
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@mhs\.itenas\.ac\.id$")
                        .hasMatch(value ?? '')) {
                      return 'Email harus domain @mhs.itenas.ac.id';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'No Telepon',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'No Telepon tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: pickImage,
                  child: Text('Pilih Foto Profil'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await DataService().updateId(
                    'username',
                    usernameController.text,
                    token,
                    project,
                    'user',
                    appid,
                    currentUser!.id,
                  );
                  await DataService().updateId(
                    'email',
                    emailController.text,
                    token,
                    project,
                    'user',
                    appid,
                    currentUser!.id,
                  );
                  await DataService().updateId(
                    'no_telpon',
                    phoneController.text,
                    token,
                    project,
                    'user',
                    appid,
                    currentUser!.id,
                  );
                  if (updatedProfpic != null) {
                    await DataService().updateId(
                      'profpic',
                      updatedProfpic!,
                      token,
                      project,
                      'user',
                      appid,
                      currentUser!.id,
                    );
                  }
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  Navigator.of(context).pop();
                  onUpdate();
                  // Tampilkan popup sukses
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Update Berhasil!',
                            style: TextStyle(color: Colors.white)),
                        content: Text(
                            'Profil Anda telah berhasil diperbarui. Mohon login kembali',
                            style: TextStyle(color: Colors.white)),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              // Logout dan arahkan ke halaman welcome_screen
                              await prefs.remove('userData');
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                'welcome_screen',
                                (route) => false,
                              );
                            },
                            child: Text('OK',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    },
                  );
                } catch (e) {
                  debugPrint('Error updating profile: $e');
                }
              }
            },
            child: Text('Simpan'),
          ),
        ],
      );
    },
  );
}
