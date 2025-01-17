import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isread/pages/peminjaman_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isread/pages/welcome_page.dart';
import 'package:isread/models/book_model.dart';
import 'package:isread/models/user_model.dart';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  final Map<String, dynamic>? userData;

  const BookDetailScreen({Key? key, required this.bookId, this.userData})
      : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isExpanded = false;
  UserModel? currentUser;
  DataService ds = DataService();
  BukuModel? buku;
  List data = [];
  int? total;
  String? borrowerEmail;

  Future<void> selectIdBuku() async {
    data = jsonDecode(
        await ds.selectId(token, project, 'buku', appid, widget.bookId));
    buku = BukuModel.fromJson(data[0]);

    if (buku?.status == "Tidak Tersedia") {
      borrowerEmail = await findBorrowerEmail(widget.bookId);
    }

    setState(() {});
  }

  Future<int> findBorrowedBook(String idUser) async {
    String response = await ds.selectWhere(
        token, project, 'peminjaman', appid, 'id_user', idUser);

    List<dynamic> peminjamanList = jsonDecode(response);

    bool dataExists = peminjamanList.any((item) =>
        item['status'] == 'Berlangsung' || item['status'] == 'Terlambat');

    if (dataExists) {
      return peminjamanList.length;
    } else {
      return 0;
    }
  }

  Future<String?> findBorrowerEmail(String idBuku) async {
    try {
      // Ambil data peminjaman berdasarkan id_buku dan status "Berlangsung"
      String response = await ds.selectWhere(
          token, project, 'peminjaman', appid, 'id_buku', idBuku);

      List<dynamic> peminjamanList = jsonDecode(response);

      // Filter data untuk mendapatkan peminjaman yang sedang berlangsung
      var ongoingLoan = peminjamanList.firstWhere(
          (item) =>
              item['status'] == 'Berlangsung' || item['status'] == 'Terlambat',
          orElse: () => null);

      if (ongoingLoan != null) {
        // Ambil id_user dari data yang ditemukan
        String idUser = ongoingLoan['id_user'];

        // Cari email pengguna berdasarkan id_user
        String? email = await findUserEmail(idUser);
        return email;
      } else {
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<String?> findUserEmail(String idUser) async {
    try {
      // Ambil data pengguna berdasarkan id_user
      String response =
          await ds.selectId(token, project, 'user', appid, idUser);

      List<dynamic> userList = jsonDecode(response);

      if (userList.isNotEmpty) {
        // Ambil email dari data pengguna yang ditemukan
        String email = userList.first['email'];
        return email;
      } else {
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    selectIdBuku();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: currentUser == null
          ? Container(
              margin: const EdgeInsets.all(25),
              height: 49,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.surface),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Login untuk Meminjam',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : buku?.status == "Tidak Tersedia"
              ? Container(
                  margin: const EdgeInsets.all(25),
                  child: Text(
                    "Buku sedang dipinjam oleh ${borrowerEmail ?? 'Error memuat data'}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                )
              : buku?.kategori_buku == "Tugas Akhir"
                  ? Container(
                      margin: const EdgeInsets.all(25),
                      child: const Text(
                        "Dokumen Tugas Akhir tidak dapat dipinjam",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(
                          left: 25, right: 25, bottom: 25),
                      height: 49,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.surface),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        onPressed: () async {
                          if (currentUser != null) {
                            int borrowedCount =
                                await findBorrowedBook(currentUser!.id);
                            if (borrowedCount == 1) {
                              // Tampilkan dialog pesan jika sudah meminjam 1 buku
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    title: const Text('Peringatan',
                                        style: TextStyle(color: Colors.black)),
                                    content: const Text(
                                      'Anda hanya dapat meminjam 1 buku.',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text(
                                          'Tutup',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              // Arahkan ke halaman PeminjamanPage jika belum meminjam buku
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PeminjamanPage(
                                    bookId: buku?.id ?? "Null",
                                    userData: widget.userData,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Pinjam Buku',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Color(0xFFF3F3E0),
              expandedHeight: MediaQuery.of(context).size.height * 0.5,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.5,
                      color: const Color(0xFFF3F3E0), // Warna latar belakang
                    ),
                    Positioned(
                      left: 25,
                      top: MediaQuery.of(context).padding.top + 20,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 62),
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: buku?.sampul_buku == "-" ||
                                  buku?.sampul_buku == null
                              ? Colors.grey[300]
                              : null,
                          image: buku?.kategori_buku == 'Umum'
                              ? DecorationImage(
                                  image: NetworkImage(
                                      fileUri + (buku?.sampul_buku ?? "")),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: AssetImage(
                                      "assets/sampul/${buku?.kategori_buku}.jpeg"),
                                  fit: BoxFit.cover,
                                ),
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
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 24, left: 25, right: 25),
                    child: Text(
                      buku?.judul_buku ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 25),
                    child: Text(
                      buku?.pengarang ?? 'Unknown Author',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 25),
                    child: Text(
                      buku?.status ?? 'Undefined',
                      style: TextStyle(
                        fontSize: 14,
                        color: buku?.status == "Tidak Tersedia"
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 25),
                    child: Text(
                      'Informasi Buku',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 25, right: 25),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment
                                  .center, // Menyusun item agar terpusat
                              child: GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent:
                                      200, // Atur lebar maksimum item grid
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio:
                                      3, // Sesuaikan rasio agar lebih proporsional
                                ),
                                itemCount: isExpanded
                                    ? (buku?.dosen_pembimbing.contains(";") ??
                                            false
                                        ? 5
                                        : 4)
                                    : 3,
                                itemBuilder: (context, index) {
                                  String label;
                                  String value;

                                  switch (index) {
                                    case 0:
                                      label = "Penerbit";
                                      value = buku?.penerbit ?? 'Lorem Ipsum';
                                      break;
                                    case 1:
                                      label = "Kategori Buku";
                                      value =
                                          buku?.kategori_buku ?? 'Lorem Ipsum';
                                      break;
                                    case 2:
                                      label = "Tahun Terbit";
                                      value =
                                          buku?.tahun_terbit ?? 'Lorem Ipsum';
                                      break;
                                    case 3:
                                      label = "Dosen Pembimbing 1";
                                      List<String> dosenPembimbing =
                                          buku?.dosen_pembimbing.split(";") ??
                                              ['Lorem Ipsum'];
                                      value = dosenPembimbing[0].trim();
                                      break;
                                    case 4:
                                      if (buku?.dosen_pembimbing
                                              .contains(";") ??
                                          false) {
                                        label = "Dosen Pembimbing 2";
                                        List<String> dosenPembimbing =
                                            buku?.dosen_pembimbing.split(";") ??
                                                [];
                                        value = dosenPembimbing.length > 1
                                            ? dosenPembimbing[1].trim()
                                            : 'Unknown';
                                      } else {
                                        label = "Unknown";
                                        value = "Lorem Ipsum";
                                      }
                                      break;
                                    default:
                                      label = "Unknown";
                                      value = "Lorem Ipsum";
                                      break;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[900],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            value,
                                            style: TextStyle(fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Icon(isExpanded
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 25),
                    child: Text(
                      'Abstrak',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 25, right: 25, bottom: 25, top: 15),
                    child: Text(
                      buku?.deskripsi ?? 'No Description Available',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
