import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:isread/models/book_model.dart';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({Key? key, required this.bookId}) : super(key: key);
  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isExpanded = false;

  DataService ds = DataService();
  BukuModel? buku;
  List data = [];
  int? total;

  Future<void> selectIdBuku() async {
    data = jsonDecode(
        await ds.selectId(token, project, 'buku', appid, widget.bookId));
    buku = BukuModel.fromJson(data[0]);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    selectIdBuku();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
        height: 49,
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.teal),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          onPressed: () {},
          child: const Text(
            'Generate Barcode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.teal,
              expandedHeight: MediaQuery.of(context).size.height * 0.5,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 25,
                      top: 20,
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
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 62),
                        width: 172,
                        height: 225,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: buku?.sampul_buku == "-" ||
                                  buku?.sampul_buku == null
                              ? Colors.grey[300]
                              : null,
                          image: buku?.sampul_buku != '-' &&
                                  buku?.sampul_buku != null
                              ? DecorationImage(
                                  image: AssetImage(
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
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 25),
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
                      style: const TextStyle(fontSize: 14, color: Colors.green),
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
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 4,
                                  crossAxisSpacing: 4,
                                  childAspectRatio: 2.7,
                                ),
                                itemCount: isExpanded
                                    ? (buku?.dosen_pembimbing.contains(";") ??
                                            false
                                        ? 5
                                        : 4) // 4 informasi + 1 dosen tambahan jika ada
                                    : 3,
                                itemBuilder: (context, index) {
                                  String label;
                                  String value;

                                  // Menyesuaikan dengan field yang ada
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
                                    case 4: // Menangani dosen pembimbing kedua
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
