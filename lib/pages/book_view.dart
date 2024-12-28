import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:isread/models/book_model.dart';
import 'package:isread/utils/config.dart';
import 'package:isread/utils/restapi.dart';

class BookView extends StatefulWidget {
  final String selectedCategory;
  const BookView({super.key, required this.selectedCategory});

  @override
  State<BookView> createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  int _selectedIndex = 1;
  TextEditingController txtSearch = TextEditingController();
  TextEditingController txtStartYear = TextEditingController();
  TextEditingController txtEndYear = TextEditingController();

  int selectTag = 0;
  List<String> tagsArr = ["All", "TA", "KP", "MBKM", "BUKU"];

  late String selectedCategory;

  DataService ds = DataService();

  List data = [];
  List<BukuModel> buku = [];
  List<BukuModel> filteredBuku = [];

  @override
  void initState() {
    super.initState();
    selectedCategory =
        widget.selectedCategory.isNotEmpty ? widget.selectedCategory : "All";
    selectTag = tagsArr.indexOf(widget.selectedCategory ?? "All");
    filterByTag(selectedCategory);
    selectAllBook();
  }

  Future<void> selectAllBook() async {
    data = jsonDecode(await ds.selectAll(token, project, 'buku', appid));

    buku = data.map((e) => BukuModel.fromJson(e)).toList();

    filterByTag(selectedCategory);
  }

  void filterByTag(String tag) {
    Map<String, String?> categoryMap = {
      "All": null,
      "TA": "Tugas Akhir",
      "KP": "Laporan Praktik Kerja",
      "MBKM": "Laporan Akhir MBKM",
      "Buku": "Buku",
    };

    setState(() {
      filteredBuku = buku.where((item) {
        String? mappedCategory = categoryMap[tag];
        return mappedCategory == null || item.kategori_buku == mappedCategory;
      }).toList();
      selectTag = tagsArr.indexOf(tag);
    });
  }

  void filterByYear() {
    String startYear = txtStartYear.text;
    String endYear = txtEndYear.text;

    if (startYear.isNotEmpty && endYear.isNotEmpty) {
      setState(() {
        filteredBuku = buku.where((item) {
          int itemYear = int.parse(item.tahun_terbit);
          return itemYear >= int.parse(startYear) &&
              itemYear <= int.parse(endYear) &&
              (selectedCategory == "All" ||
                  item.kategori_buku ==
                      (selectedCategory == "All" ? null : selectedCategory));
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
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
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredBuku = buku
                                .where((item) =>
                                    item.judul_buku
                                        .toLowerCase()
                                        .contains(value.toLowerCase()) ||
                                    item.pengarang
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                .toList();
                          });
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
                          showModalBottomSheet(
                            backgroundColor: Colors.white,
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Filter Berdasarkan Tahun",
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 20.0),
                                    TextField(
                                      controller: txtStartYear,
                                      decoration: InputDecoration(
                                        labelText: "Tahun Mulai",
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 10.0),
                                    TextField(
                                      controller: txtEndYear,
                                      decoration: InputDecoration(
                                        labelText: "Tahun Selesai",
                                        labelStyle: TextStyle(
                                            color: Colors
                                                .black), // warna label putih agar terlihat di atas latar hitam
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 20.0),
                                    ElevatedButton(
                                      onPressed: () {
                                        filterByYear();
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Terapkan Filter"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: tagsArr.map((tagName) {
                  var index = tagsArr.indexOf(tagName);
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectTag = index;
                        });
                        filterByTag(tagName);
                      },
                      child: Text(
                        tagName,
                        style: TextStyle(
                            color:
                                selectTag == index ? Colors.black : Colors.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: filteredBuku.isEmpty
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredBuku
                          .length, // Menampilkan 5 placeholder saat data belum tersedia
                      itemBuilder: (context, index) {
                        return Container(
                          width: 165,
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        );
                      },
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.75,
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: filteredBuku.length,
                    itemBuilder: (context, index) {
                      var bukuItem = filteredBuku[index];
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    heightFactor: 1.0,
                                    child: Image.network(
                                      bukuItem.sampul_buku,
                                      fit: BoxFit.fill,
                                      height: 225.0,
                                      width: 165,
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Perbarui tab yang aktif
          });

          // Navigasi hanya jika halaman berbeda
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
