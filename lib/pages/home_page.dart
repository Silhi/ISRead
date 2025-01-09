import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isread/theme/color_extenstion.dart';
import 'package:isread/pages/welcome_page.dart';
import 'package:isread/pages/book_detail_page.dart';
import 'package:isread/pages/book_page.dart';
import 'package:isread/models/book_model.dart';
import 'package:isread/models/user_model.dart';
import 'package:isread/utils/config.dart';
import 'package:isread/utils/restapi.dart';

class HomeView extends StatefulWidget {
  final Function(String) onCategorySelected;
  const HomeView({super.key, required this.onCategorySelected});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();
  DataService ds = DataService();
  List data = [];
  List<BukuModel> buku = [];
  List<BukuModel> search_data = [];
  List<BukuModel> search_data_pre = [];
  int _selectedIndex = 0;
  int selectTag = 0;

  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    processUserData();
    selectAllBook();
  }

  Future<void> processUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    if (userData != null && userData.isNotEmpty) {
      setState(() {
        currentUser = UserModel.fromJson(jsonDecode(userData));
      });
    }
  }

  Future<void> selectAllBook() async {
    data = jsonDecode(await ds.selectAll(token, project, 'buku', appid));

    buku = data.map((e) => BukuModel.fromJson(e)).toList();

    setState(() {
      buku = buku;
    });
  }

  void filterBook(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      search_data = data.map((e) => BukuModel.fromJson(e)).toList();
    } else {
      search_data_pre = data.map((e) => BukuModel.fromJson(e)).toList();
      search_data = search_data_pre
          .where((buku) =>
              buku.judul_buku
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              buku.dosen_pembimbing.contains(enteredKeyword.toLowerCase()) ||
              buku.pengarang.contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      buku = search_data;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Align(
                    child: Transform.scale(
                      scale: 1.5,
                      origin: Offset(0, media.width * 0.8),
                      child: Container(
                        width: media.width,
                        height: media.width * 1.50,
                        decoration: BoxDecoration(
                            color: TColor.primaryLight,
                            borderRadius:
                                BorderRadius.circular(media.width * 0.5)),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              height: media.width * 0.34,
                            ),
                            Expanded(
                              child: TextField(
                                controller: txtSearch,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search),
                                  hintText: "Telusuri koleksi",
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookView(selectedCategory: "All"),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.calendar_month_outlined),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookView(selectedCategory: "All"),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Welcome message container
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            currentUser != null
                                ? CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.blue[100],
                                    child: ClipOval(
                                      child: Image.asset(
                                        "/avatar/dummy.jpg",
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context,
                                            Object error,
                                            StackTrace? stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            size: 30,
                                            color: Colors.blueGrey,
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                : const CircleAvatar(
                                    radius: 30,
                                    child: Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                            const SizedBox(width: 16.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Hai Selamat Datang,",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                currentUser != null
                                    ? Text(
                                        currentUser!.nrp,
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  WelcomeScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Login",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Center(
                          child: Text(
                            "Koleksi Terbaru",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: media.width,
                        height: media.width * 0.9,
                        child: buku.isEmpty
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: media.width * 0.45,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : CarouselSlider.builder(
                                itemCount: buku.take(5).length,
                                itemBuilder: (BuildContext context,
                                    int itemIndex, int pageViewIndex) {
                                  var bukuItem = buku[itemIndex];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BookDetailScreen(
                                                  bookId: bukuItem.id),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Gambar buku
                                            Expanded(
                                              child: Image.asset(
                                                "assets/sampul/${bukuItem.kategori_buku}.jpeg",
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder: (BuildContext
                                                        context,
                                                    Object error,
                                                    StackTrace? stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons
                                                            .my_library_books_rounded,
                                                        size: 50,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            // Detail buku
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    bukuItem.judul_buku,
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Text(
                                                    bukuItem.pengarang,
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.grey,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  autoPlay: false,
                                  aspectRatio: 1,
                                  enlargeCenterPage: true,
                                  viewportFraction: 0.45,
                                  enlargeFactor: 0.4,
                                  enlargeStrategy:
                                      CenterPageEnlargeStrategy.zoom,
                                ),
                              ),
                      ),

                      SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              "Categories",
                              style: TextStyle(
                                  color: TColor.text,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: media.width * 0.25,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: 4, // Ada 4 kategori yang ditampilkan
                          itemBuilder: ((context, index) {
                            // List kategori dengan ikon dan teks
                            List<Map<String, dynamic>> categories = [
                              {
                                'icon': Icons.school,
                                'label': 'TA'
                              }, // TA: Tugas Akhir
                              {
                                'icon': Icons.computer,
                                'label': 'KP'
                              }, // KP: Kerja Praktek
                              {
                                'icon': Icons.business,
                                'label': 'MBKM'
                              }, // MBKM: Merdeka Belajar Kampus Merdeka
                              {
                                'icon': Icons.book,
                                'label': 'BUKU'
                              }, // BUKU: Buku
                            ];

                            var category = categories[index];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectTag = index;
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookView(
                                      selectedCategory: category['label'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: media.width * 0.2,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: TColor.primary,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black38,
                                      offset: Offset(0, 2),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      category['icon'],
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category['label'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Section Tugas Akhir
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(children: [
                          Text(
                            "Tugas Akhir",
                            style: TextStyle(
                              color: TColor.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(
                        width: media.width,
                        height: media.width * 1,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 8),
                          scrollDirection: Axis.horizontal,
                          itemCount: buku
                              .where((b) => b.kategori_buku == 'Tugas Akhir')
                              .length,
                          itemBuilder: (context, index) {
                            var tugasAkhirBuku = buku
                                .where((b) => b.kategori_buku == 'Tugas Akhir')
                                .toList();
                            var bukuItem = tugasAkhirBuku[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookDetailScreen(bookId: bukuItem.id),
                                  ),
                                );
                              },
                              child: Container(
                                width: media.width * 0.45,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          "assets/sampul/${bukuItem.kategori_buku}.jpeg",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (BuildContext context,
                                              Object error,
                                              StackTrace? stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(
                                                  Icons
                                                      .my_library_books_rounded,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      bukuItem.judul_buku,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      bukuItem.pengarang,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                      // Section Kerja Praktik
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(children: [
                          Text(
                            "Kerja Praktik",
                            style: TextStyle(
                              color: TColor.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(
                        width: media.width,
                        height: media.width * 1,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 8),
                          scrollDirection: Axis.horizontal,
                          itemCount: buku
                              .where((b) =>
                                  b.kategori_buku == 'Laporan Praktik Kerja')
                              .length,
                          itemBuilder: (context, index) {
                            var kerjaPraktikBuku = buku
                                .where((b) =>
                                    b.kategori_buku == 'Laporan Praktik Kerja')
                                .toList();
                            var bukuItem = kerjaPraktikBuku[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookDetailScreen(bookId: bukuItem.id),
                                  ),
                                );
                              },
                              child: Container(
                                width: media.width * 0.45,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          "assets/sampul/${bukuItem.kategori_buku}.jpeg",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (BuildContext context,
                                              Object error,
                                              StackTrace? stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(
                                                  Icons
                                                      .my_library_books_rounded,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      bukuItem.judul_buku,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      bukuItem.pengarang,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )
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
