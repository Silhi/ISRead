import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isread/models/book_model.dart';
import 'package:isread/models/return_model.dart';
import 'package:isread/models/loan_model.dart';
import 'package:isread/models/user_model.dart';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';
import 'package:intl/intl.dart';

class ReturnDashboard extends StatefulWidget {
  const ReturnDashboard({Key? key}) : super(key: key);

  @override
  ReturnDashboardState createState() => ReturnDashboardState();
}

class ReturnDashboardState extends State<ReturnDashboard> {
  final DataService ds = DataService();
  List<BukuModel> buku = [];
  List<UserModel> users = [];
  List<PeminjamanModel> pinjam = [];
  List<PengembalianModel> kembali = [];

  int totalBooks = 0;
  int totalUsers = 0;
  int totalPinjam = 0;
  int totalKembali = 0;

  String searchQuery = '';
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final rawDataBuku = await ds.selectAll(token, project, 'buku', appid);
      final dataBuku = jsonDecode(rawDataBuku) as List;
      final List<BukuModel> bukuData =
          dataBuku.map((e) => BukuModel.fromJson(e)).toList();

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
        users = usersData;
        pinjam = pinjamData;
        kembali = kembalisData;

        totalBooks = bukuData.length;
        totalUsers = usersData.length;
        totalPinjam = pinjamData.length;
        totalKembali = kembalisData.length;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
      kembali = kembali.where((item) {
        final idPinjamLower = item.id_pinjam.toLowerCase();
        final queryLower = query.toLowerCase();
        return idPinjamLower.contains(queryLower);
      }).toList();
    });
  }

  void _toggleFab() {
    setState(() {
      _isFabVisible = !_isFabVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Manage Returns',
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
                  Navigator.pushNamed(context, 'book_dashboard');
                },
                hoverColor: Colors.grey[200],
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text('Manage Users'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'manage_user');
                },
                hoverColor: Colors.grey[200],
              ),
              ListTile(
                leading: Icon(Icons.library_books, color: Colors.blue),
                title: Text('Manage Borrowing'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'manage_borrow');
                },
                hoverColor: Colors.grey[200],
              ),
              ListTile(
                leading: Icon(Icons.library_add_check, color: Colors.blue),
                title: Text('Manage Returns'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'manage_return');
                },
                hoverColor: Colors.grey[200],
              ),
              ListTile(
                leading: Icon(Icons.history, color: Colors.blue),
                title: Text('History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'history');
                },
                hoverColor: Colors.grey[200],
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.blue),
                title: Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'welcome_screen');
                },
                hoverColor: Colors.grey[200],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Konten utama termasuk DataTable
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                statisticsGrid(pinjam),
                filterAndSearchSection(),
                dataTable(context, kembali, pinjam),
              ],
            ),
          ),
          // Tombol panah untuk kontrol FAB
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
            ),
          ),
        ],
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
          Row(
            children: [
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
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search by Loan ID...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.blue, width: 2.0), // Blue border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0), // Blue border when focused
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 209, 209, 209),
                          width: 2.0), // Blue border when enabled
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history, color: Colors.blue),
                onPressed: () {
                  Navigator.pushNamed(context, 'history');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget statisticsGrid(List<PeminjamanModel> borrows) {
    // Hitung total peminjaman yang statusnya bukan 'selesai'
    int totalPinjam =
        borrows.where((borrow) => borrow.status != 'Selesai').length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double cardWidth = (constraints.maxWidth - 48) / 2;
          if (constraints.maxWidth > 600) {
            cardWidth = (constraints.maxWidth - 72) / 3;
          }
          if (constraints.maxWidth > 900) {
            cardWidth = (constraints.maxWidth - 96) / 4;
          }

          return Wrap(
            spacing: 18,
            runSpacing: 16,
            children: [
              statsCard('Users', totalUsers, Colors.blue, Icons.people,
                  cardWidth, 'manage_user'),
              statsCard('Books', totalBooks, Colors.green, Icons.book,
                  cardWidth, 'book_dashboard'),
              statsCard('Borrows', totalPinjam, Colors.orange,
                  Icons.shopping_cart, cardWidth, 'manage_borrow'),
              statsCard('Returns', totalKembali, Colors.red,
                  Icons.assignment_return, cardWidth, 'manage_return'),
            ],
          );
        },
      ),
    );
  }

  Widget statsCard(String title, int count, Color color, IconData icon,
      double width, String routeName) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        width: width,
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
                  fontSize: 30, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget dataTable(
      BuildContext context,
      List<PengembalianModel> pengembalianList,
      List<PeminjamanModel> peminjamanList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      headingRowColor:
                          MaterialStateProperty.all(Colors.grey[200]),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    child: DataTable(
                      columnSpacing: 16.0,
                      horizontalMargin: 12.0,
                      dataRowHeight: 70.0,
                      headingRowHeight: 50.0,
                      columns: [
                        DataColumn(
                            label: const Text('ID Pinjam',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: const Text('Tanggal Dikembalikan',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: const Text('Bukti Foto',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: pengembalianList.map((kembali) {
                        return DataRow(
                          cells: [
                            DataCell(Text(kembali.id_pinjam)),
                            DataCell(Text(kembali.tgl_dikembalikan)),
                            DataCell(
                              kembali.bukti_foto.isNotEmpty
                                  ? (kembali.bukti_foto.startsWith('http')
                                      ? Image.network(kembali.bukti_foto,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover)
                                      : Image.asset(kembali.bukti_foto,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover))
                                  : Text('-'), // Display '-' if no photo
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
