import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isread/utils/config.dart' as Config;
import 'package:isread/utils/restapi.dart';
import 'package:isread/models/book_model.dart';

class EditBookPage extends StatefulWidget {
  const EditBookPage({Key? key}) : super(key: key);

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final DataService ds = DataService();

  final _judulController = TextEditingController();
  final _pengarangController = TextEditingController();
  final _penerbitController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _tahunController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _kodeController = TextEditingController();

  final _statusOptions = ['Tersedia', 'Dipinjam'];
  String? _selectedStatus;
  String? _selectedLocalImage;

  final _editBookFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _localImages = [
    'assets/sampul/Laporan Akhir MBKM.jpeg',
    'assets/sampul/Laporan Praktik Kerja.jpeg',
    'assets/sampul/Sistem Informasi Perusahaan.jpeg',
    'assets/sampul/Tugas Akhir.jpeg',
  ];

  String? bookId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as List?;
    if (args != null && args.isNotEmpty) {
      bookId = args[0] as String?;
      if (bookId != null) {
        _fetchBookDetails();
      }
    }
  }

  Future<void> _fetchBookDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ds.selectId(
        Config.token,
        Config.project,
        'buku',
        Config.appid,
        bookId!,
      );

      final data = jsonDecode(response) as List<dynamic>;
      if (data.isNotEmpty) {
        final book = BukuModel(
          id: data[0]['_id'],
          judul_buku: data[0]['judul_buku'],
          pengarang: data[0]['pengarang'],
          penerbit: data[0]['penerbit'],
          kategori_buku: data[0]['kategori_buku'],
          tahun_terbit: data[0]['tahun_terbit'],
          sampul_buku: data[0]['sampul_buku'],
          status: data[0]['status'],
          deskripsi: data[0]['deskripsi'],
          dosen_pembimbing: data[0]['dosen_pembimbing'],
          kode_buku: data[0]['kode_buku'],
        );

        setState(() {
          _judulController.text = book.judul_buku ?? '';
          _pengarangController.text = book.pengarang ?? '';
          _penerbitController.text = book.penerbit ?? '';
          _kategoriController.text = book.kategori_buku ?? '';
          _tahunController.text = book.tahun_terbit ?? '';
          _deskripsiController.text = book.deskripsi ?? '';
          _selectedStatus = book.status;

          // Mengatur sampul buku yang sudah ada jika ada
          if (_localImages.contains(book.sampul_buku)) {
            _selectedLocalImage = book.sampul_buku;
          } else {
            // Jika sampul buku tidak ada dalam daftar lokal, pilih default
            _selectedLocalImage = _localImages.first;
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load book details: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSubmit() async {
    if (_editBookFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updateStatus = await ds.updateId(
          'judul_buku~pengarang~penerbit~kategori_buku~tahun_terbit~deskripsi~status~sampul_buku~dosen_pembimbing~kode_buku',
          '${_judulController.text}~${_pengarangController.text}~${_penerbitController.text}~${_kategoriController.text}~${_tahunController.text}~${_deskripsiController.text}~$_selectedStatus~$_selectedLocalImage~dosen_pembimbing~${_kodeController.text}',
          Config.token,
          Config.project,
          'buku',
          Config.appid,
          bookId!,
        );

        if (updateStatus) {
          // Kembali ke halaman sebelumnya dengan hasil sukses
          Navigator.pop(context, true);
        } else {
          setState(() {
            _errorMessage =
                'Failed to update book details. Please try again later.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage =
              'An error occurred during the update: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Book',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'book_dashboard');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Form(
            key: _editBookFormKey,
            child: Column(
              children: [
                const Text(
                  '📚 Edit a Book',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField('Judul Buku', _judulController),
                _buildTextField('Pengarang', _pengarangController),
                _buildTextField('Penerbit', _penerbitController),
                _buildTextField('Kategori', _kategoriController),
                _buildTextField('Tahun Terbit', _tahunController,
                    keyboardType: TextInputType.number),
                _buildDeskripsiField(),
                _buildDropdown(),
                _buildImagePicker(),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _onSubmit,
                  child: const Text('Update'),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedStatus,
        decoration: InputDecoration(
          labelText: 'Status',
          labelStyle: const TextStyle(color: Colors.blueAccent),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          border: const OutlineInputBorder(),
        ),
        items: _statusOptions
            .map((status) =>
                DropdownMenuItem(value: status, child: Text(status)))
            .toList(),
        onChanged: (value) => setState(() => _selectedStatus = value),
        validator: (value) => value == null ? 'Please select a status' : null,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildDeskripsiField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _deskripsiController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Deskripsi',
          labelStyle: const TextStyle(color: Colors.blueAccent),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter Deskripsi' : null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menampilkan gambar sampul yang dipilih
          if (_selectedLocalImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Image.asset(
                _selectedLocalImage!,
                height: 100, // Ukuran gambar yang lebih besar
                width: 100,
                fit: BoxFit.cover, // Menjaga proporsi gambar
              ),
            ),
          // Dropdown untuk memilih sampul buku
          DropdownButtonFormField<String>(
            value: _selectedLocalImage,
            decoration: InputDecoration(
              labelText: 'Sampul Buku',
              labelStyle: const TextStyle(color: Colors.blueAccent),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              border: const OutlineInputBorder(),
            ),
            items: _localImages
                .map((path) => DropdownMenuItem(
                      value: path,
                      child: Row(
                        children: [
                          Image.asset(path, height: 50, width: 50),
                          const SizedBox(width: 10),
                          Text(path.split('/').last),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedLocalImage = value;
                print("Sampul yang dipilih: $_selectedLocalImage");
              });

              // Debugging: cek apakah nilai sampul terupdate
              print("Sampul yang dipilih: $_selectedLocalImage");
            },
            validator: (value) =>
                value == null ? 'Please select a cover image' : null,
          ),
        ],
      ),
    );
  }
}
