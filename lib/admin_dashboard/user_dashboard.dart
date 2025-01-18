import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isread/models/book_model.dart';
import 'package:isread/models/return_model.dart';
import 'package:isread/models/loan_model.dart';
import 'package:isread/models/user_model.dart';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';
import 'package:intl/intl.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  UserDashboardState createState() => UserDashboardState();
}

class UserDashboardState extends State<UserDashboard> {
  final DataService ds = DataService();
  List<BukuModel> buku = [];
  List<BukuModel> filteredBuku = [];
  List<UserModel> filteredUsers = [];
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

  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch data concurrently
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
        filteredUsers = usersData;

        totalBooks = bukuData.length;
        totalUsers = usersData.length;
        totalPinjam = pinjamData.length;
        totalKembali = kembalisData.length;

        filteredBuku = buku;
        filteredPinjam = pinjam;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredUsers = users.where((item) {
        final usernameLower = item.username.toLowerCase();
        final queryLower = query.toLowerCase();
        return usernameLower.contains(queryLower);
      }).toList();
    });
  }

  void onFilter(String? role) {
    setState(() {
      filterCategory = role ?? '';
      filteredUsers = users.where((item) {
        if (role == null || role.isEmpty)
          return true; // Tampilkan semua jika tidak ada filter
        return item.role.toLowerCase() == role.toLowerCase();
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
          'Manage User',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
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
                dataTable(context),
              ],
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
              IconButton(
                icon: const Icon(Icons.history, color: Colors.blue),
                onPressed: () {
                  Navigator.pushNamed(context,
                      'history'); // Ganti 'history' dengan nama rute yang sesuai
                },
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
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearch,
                  cursorColor: Colors.blueAccent,
                  decoration: InputDecoration(
                    hintText: 'Search by Name...',
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
              const SizedBox(width: 10),
              DropdownButton<String?>(
                value: filterCategory.isEmpty ? null : filterCategory,
                hint: const Text("Filter by"),
                icon: const Icon(Icons.filter_list_alt),
                dropdownColor: Colors.white,
                items: [
                  const DropdownMenuItem(value: '', child: Text('All')),
                  ...users
                      .map((e) => e.role)
                      .toSet()
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
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

  Widget dataTable(BuildContext context) {
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
                            label: const Text('Username',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: const Text('NRP',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: const Text('Email',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: const Text('No Telepon',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: const Text('Role',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: const Text('Action',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: filteredUsers.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user.username,
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DataCell(Text(user.nrp,
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DataCell(Text(user.email,
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DataCell(Text(user.no_telpon,
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DataCell(Text(user.role,
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DataCell(
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                          'edit_user_page',
                                          arguments: {
                                            'userId': user.id
                                          }).then((result) {
                                        if (result == true) {
                                          fetchData();
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      // Show confirmation dialog
                                      bool? shouldDelete =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.grey[100],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            title: const Text(
                                              'Konfirmasi Hapus',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: const Text(
                                              'Apakah Anda yakin ingin menghapus pengguna ini?',
                                              style: TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text(
                                                  'Batal',
                                                  style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  'Hapus',
                                                  style: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      // If the user confirms deletion
                                      if (shouldDelete == true) {
                                        bool response = await ds.removeId(
                                          token,
                                          project,
                                          'user', // Ensure this matches the correct entity
                                          appid,
                                          user.id, // Use the correct user ID
                                        );

                                        if (response) {
                                          setState(() {
                                            // Remove the user from the list and update totals
                                            users.removeWhere(
                                                (item) => item.id == user.id);
                                            totalUsers = users
                                                .length; // Update the total count
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'Pengguna berhasil dihapus!'),
                                            backgroundColor: Colors.green,
                                          ));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'Gagal menghapus pengguna dari database.'),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
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
