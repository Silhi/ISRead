import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isread/utils/config.dart' as Config;
import 'package:isread/utils/restapi.dart';
import 'package:isread/models/book_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

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
  final _kodeBukuController = TextEditingController();
  final _dosenPebimbingController = TextEditingController();
  final _kodeController = TextEditingController();

  final _statusOptions = ['Tersedia', 'Dipinjam'];
  String? _selectedStatus;
  String? _selectedLocalImage;
  String? sampul_buku;
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
  void initState() {
    super.initState();
    _fetchBookDetails();
  }

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
          _kodeBukuController.text = book.kode_buku ?? '';
          _dosenPebimbingController.text = book.dosen_pembimbing ?? '';
          _selectedStatus = book.status;

          // Set existing book cover if available
          if (_localImages.contains(book.sampul_buku)) {
            _selectedLocalImage = book.sampul_buku;
          } else {
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
          '${_judulController.text}~${_pengarangController.text}~${_penerbitController.text}~${_kategoriController.text}~${_tahunController.text}~${_deskripsiController.text}~$_selectedStatus~$_selectedLocalImage~${_dosenPebimbingController.text}~${_kodeBukuController.text}',
          Config.token,
          Config.project,
          'buku',
          Config.appid,
          bookId!,
        );

        if (updateStatus) {
          // Return to the previous page after successful update
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
                _buildTextField('NRP Penulis', _penerbitController),
                _buildTextField('Kategori', _kategoriController),
                _buildTextField('Tahun Terbit', _tahunController,
                    keyboardType: TextInputType.number),
                _buildImagePicker(),
                _buildDropdown(),
                _buildDeskripsiField(),
                _buildTextField('Dosen Pebimbing', _dosenPebimbingController),
                _buildTextField('Kode_Buku', _kodeBukuController),
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
          // Ensure cursor color is black
        ),
        cursorColor: Colors.black,
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
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
        items: _statusOptions
            .map(
              (status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedStatus = value;
          });
        },
        validator: (value) => value == null ? 'Please select a status' : null,
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
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          // Ensure cursor color is black
        ),
        cursorColor: Colors.black,
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter a description' : null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Pilih Sampul Buku'),
          DropdownButton<String>(
            value: _selectedLocalImage,
            onChanged: (newValue) {
              setState(() {
                _selectedLocalImage = newValue!;
              });
            },
            items: _localImages
                .map((image) => DropdownMenuItem<String>(
                      value: image,
                      child: Text(image.split('/').last),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
