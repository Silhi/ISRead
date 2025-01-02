import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:isread/models/book_model.dart';
import 'package:isread/models/return_model.dart';
import 'package:isread/models/loan_model.dart';
import 'package:isread/models/user_model.dart';

import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';
import 'package:intl/intl.dart';

import 'package:isread/admin_dashboard/book_details.dart';

class BookDashboard extends StatefulWidget {
  const BookDashboard({Key? key}) : super(key: key);

  @override
  BookDashboardState createState() => BookDashboardState();
}

class BookDashboardState extends State<BookDashboard> {
  final DataService ds = DataService();
  List<BukuModel> buku = [];
  List<BukuModel> filteredBuku = [];
  List<UserModel> users = [];
  List<PeminjamanModel> pinjam = [];
  List<PengembalianModel> kembali = [];
  List<PeminjamanModel> filteredPinjam = [];

  int totalBooks = 0;
  int totalUsers = 0;
  int totalPinjam = 0;
  int totalKembali = 0;

  String searchQuery = '';
  String filterCategory = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch Buku data
      final rawDataBuku = await ds.selectAll(token, project, 'buku', appid);
      final dataBuku = jsonDecode(rawDataBuku) as List;
      final List<BukuModel> bukuData =
          dataBuku.map((e) => BukuModel.fromJson(e)).toList();

      // Fetch User data
      final rawDataUsers = await ds.selectAll(token, project, 'user', appid);
      final dataUsers = jsonDecode(rawDataUsers) as List;
      final List<UserModel> usersData =
          dataUsers.map((e) => UserModel.fromJson(e)).toList();

      final rawDataPinjam =
          await ds.selectAll(token, project, 'peminjaman', appid);
      final dataPinjam = jsonDecode(rawDataPinjam) as List;
      final List<PeminjamanModel> pinjamData =
          dataPinjam.map((e) => PeminjamanModel.fromJson(e)).toList();

      final rawDatakembalis =
          await ds.selectAll(token, project, 'pengembalian', appid);
      final datakembalis = jsonDecode(rawDatakembalis) as List;
      final List<PengembalianModel> kembalisData =
          datakembalis.map((e) => PengembalianModel.fromJson(e)).toList();

      setState(() {
        buku = bukuData;
        totalBooks = bukuData.length;
        users = usersData;
        totalUsers = usersData.length;
        pinjam = pinjamData;
        totalPinjam = pinjamData.length;
        kembali = kembalisData;
        totalKembali = kembalisData.length;

        filteredBuku = buku;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredBuku = buku.where((item) {
        final titleLower = item.judul_buku.toLowerCase();
        final queryLower = query.toLowerCase();
        return titleLower.contains(queryLower);
      }).toList();
    });
  }

  void onFilter(String? category) {
    setState(() {
      filterCategory = category ?? '';
      filteredBuku = buku.where((item) {
        if (category == null || category.isEmpty) return true;
        return item.kategori_buku.toLowerCase() == category.toLowerCase();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Manage Books',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white, // Ubah warna latar belakang drawer menjadi putih
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                color: Colors.blue, // Warna latar belakang header drawer
                padding: EdgeInsets.only(left: 16.0, top: 20.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/avatar/dummy.jpg'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Admin Name',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'admin@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: Colors.blue),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                },
                hoverColor:
                    Colors.grey[200], // Efek abu-abu saat kursor diarahkan
              ),
              ListTile(
                leading: Icon(Icons.book, color: Colors.blue),
                title: Text('Manage Books'),
                onTap: () {
                  Navigator.pop(context);
                },
                hoverColor: Colors.grey[200],
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text('Manage Users'),
                onTap: () {
                  Navigator.pop(context);
                },
                hoverColor: Colors.grey[200],
              ),
              ListTile(
                leading: Icon(Icons.library_books, color: Colors.blue),
                title: Text('Manage Borrowing'),
                onTap: () {
                  Navigator.pop(context);
                },
                hoverColor: Colors.grey[200],
              ),
              ListTile(
                leading: Icon(Icons.library_add_check, color: Colors.blue),
                title: Text('Manage Returns'),
                onTap: () {
                  Navigator.pop(context);
                },
                hoverColor: Colors.grey[200],
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.blue),
                title: Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'login_page');
                },
                hoverColor: Colors.grey[200],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            statisticsGrid(),
            triggerSection(),
            filterAndSearchSection(),
            dataTable(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'add_book_page');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Book',
      ),
    );
  }

  Widget filterAndSearchSection() {
    DateTime today = DateTime.now();

    String formattedToday = DateFormat('yyyy, MMM d').format(today);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Manage your book collection",
            style: TextStyle(
              color: Color.fromARGB(255, 107, 105, 105),
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            "Sistem Informasi ITENAS",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextButton.icon(
            icon: Icon(
              Icons.calendar_today, // Ikon kalender untuk tanggal
              color: const Color.fromARGB(255, 11, 15, 255), // Warna ikon
            ),
            onPressed: () {
              // Fungsi ketika tombol ditekan
            },
            label: Text(
              "Date: $formattedToday",
              style: TextStyle(
                color: const Color.fromARGB(255, 11, 15, 255), // Warna teks
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search by book title...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String?>(
                value: filterCategory.isEmpty ? null : filterCategory,
                hint: Text("Filter by"),
                icon: Icon(Icons.filter_list_alt),
                dropdownColor: Colors.white,
                items: [
                  const DropdownMenuItem(value: '', child: Text('All')),
                  ...buku
                      .map((e) => e.kategori_buku)
                      .toSet()
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                ],
                onChanged: onFilter,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget statisticsGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Menentukan lebar tiap card berdasarkan ukuran halaman
          double cardWidth = (constraints.maxWidth - 48) /
              2; // 48 = spacing Wrap (18) + padding Wrap (16 x 2)
          if (constraints.maxWidth > 600) {
            cardWidth = (constraints.maxWidth - 72) /
                3; // Jika layar lebih lebar, tampilkan 3 card per baris
          }
          if (constraints.maxWidth > 900) {
            cardWidth = (constraints.maxWidth - 96) /
                4; // Jika layar sangat lebar, tampilkan 4 card per baris
          }

          return Wrap(
            spacing: 18, // Jarak horizontal antar card
            runSpacing: 16, // Jarak vertikal antar card
            children: [
              statsCard(
                  'Users', totalUsers, Colors.blue, Icons.people, cardWidth),
              statsCard(
                  'Books', totalBooks, Colors.green, Icons.book, cardWidth),
              statsCard('Borrows', totalPinjam, Colors.orange,
                  Icons.shopping_cart, cardWidth),
              statsCard('Returns', totalKembali, Colors.red,
                  Icons.assignment_return, cardWidth),
            ],
          );
        },
      ),
    );
  }

  Widget statsCard(
      String title, int count, Color color, IconData icon, double width) {
    return Container(
      width: width, // Lebar card sesuai hasil perhitungan responsif
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            "$count ${title == 'Books' ? 'Books' : title == 'Users' ? 'Users' : title == 'Borrows' ? 'Borrows' : 'Returns'}",
            style: TextStyle(
              fontSize: 30,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget triggerSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Add PDF export functionality
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Export PDF"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Warna tombol untuk Export PDF
              foregroundColor: Colors.white, // Warna teks dan ikon
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Add scan label functionality
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("Generate Code"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Warna tombol untuk Scan Label
              foregroundColor: Colors.white, // Warna teks dan ikon
            ),
          ),
        ],
      ),
    );
  }

  Widget dataTable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTableTheme(
                    data: DataTableThemeData(
                      headingRowColor: MaterialStateProperty.all(
                          Colors.grey[200]), // Warna header
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ), // Gaya teks header
                    ),
                    child: DataTable(
                      columnSpacing: 16.0, // Spasi antar kolom
                      horizontalMargin: 12.0, // Margin horizontal
                      dataRowHeight: 70.0, // Tinggi baris data
                      headingRowHeight: 50.0, // Tinggi baris heading
                      columns: const [
                        DataColumn(
                          label: Text('Title',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Category',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Author',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Action',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      rows: filteredBuku.map((book) {
                        return DataRow(
                          cells: [
                            DataCell(
                              GestureDetector(
                                onTap: () {
                                  // Navigasi ke halaman detail
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookDetailPage(book: book),
                                    ),
                                  );
                                },
                                child: Container(
                                  width:
                                      constraints.maxWidth * 0.60, // Lebar 60%
                                  child: Text(
                                    book.judul_buku,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: constraints.maxWidth * 0.20, // Lebar 20%
                                child: Text(
                                  book.kategori_buku,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: constraints.maxWidth * 0.20, // Lebar 20%
                                child: Text(
                                  book.pengarang,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        'edit_book_page',
                                        arguments: [book.id],
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      bool response = await ds.removeId(
                                        token,
                                        project,
                                        'buku',
                                        appid,
                                        book.id, // Pastikan ID buku yang benar dikirim
                                      );

                                      if (response) {
                                        setState(() {
                                          // Hapus buku dari daftar yang ditampilkan
                                          filteredBuku.removeWhere(
                                              (item) => item.id == book.id);
                                          buku.removeWhere(
                                              (item) => item.id == book.id);
                                          totalBooks = buku.length;
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'Book successfully removed!'),
                                          backgroundColor: Colors.green,
                                        ));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'Failed to remove book from database.'),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
