import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart' as Config;

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _addBookFormKey = GlobalKey<FormState>();

  final _judulTextController = TextEditingController();
  final _pengarangTextController = TextEditingController();
  final _penerbitTextController = TextEditingController();
  final _kategoriTextController = TextEditingController();
  final _tahunTerbitTextController = TextEditingController();
  final _statusOptions = ['Tersedia', 'Dipinjam'];
  String? _selectedStatus;
  final _deskripsiTextController = TextEditingController();
  final _dosenPembimbingTextController = TextEditingController();
  final _kodeTextController = TextEditingController();

  XFile? _pickedImage;
  String? _selectedLocalImage;
  bool _isLoading = false;
  String? _errorMessage;

  final DataService ds = DataService(); // Instance REST API service

  final List<String> _localImages = [
    'assets/sampul/Laporan Akhir MBKM.jpeg',
    'assets/sampul/Laporan Praktik Kerja.jpeg',
    'assets/sampul/Sistem Informasi Perusahaan.jpeg',
    'assets/sampul/Tugas Akhir.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Add Book',
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
            key: _addBookFormKey,
            child: Column(
              children: [
                const Text(
                  '📚 Add a New Book',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField('Judul Buku', _judulTextController),
                _buildTextField('Pengarang', _pengarangTextController),
                _buildTextField('Penerbit', _penerbitTextController),
                _buildTextField('Kategori Buku', _kategoriTextController),
                _buildYearField(),
                _buildImagePicker(),
                _buildDropdown(),
                _buildDeskripsiField(),
                _buildTextField(
                  'Dosen Pembimbing',
                  _dosenPembimbingTextController,
                ),
                _buildTextField('Kode Buku', _kodeTextController),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
        cursorColor: Colors.blueAccent, // Warna kursor teks
        cursorWidth: 2.0, // Lebar kursor teks
        cursorRadius: const Radius.circular(4.0), // Radius ujung kursor
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(color: Colors.blue),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
          ),
        ),
      ),
    );
  }

  Widget _buildYearField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _tahunTerbitTextController,
        keyboardType: TextInputType.number,
        validator: (value) =>
            value!.isEmpty ? 'Please enter Tahun Terbit' : null,
        decoration: InputDecoration(
          labelText: 'Tahun Terbit',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(color: Colors.blue),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Status',
          labelStyle: const TextStyle(color: Colors.blue),
          filled: true,
          fillColor: Colors.white, // Warna latar belakang putih
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
        dropdownColor: Colors.white, // Warna latar belakang dropdown
        value: _selectedStatus,
        items: _statusOptions
            .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
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

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          DropdownButton<String>(
            hint: const Text('Pilih Sampul Buku'),
            value: _selectedLocalImage,
            items: _localImages
                .map((path) => DropdownMenuItem(
                      value: path,
                      child: Image.asset(
                        path,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedLocalImage = value;
                _pickedImage = null;
              });
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text('Upload Foto Lain'),
          ),
          const SizedBox(height: 10),
          if (_selectedLocalImage != null)
            Image.asset(_selectedLocalImage!, height: 100),
          if (_pickedImage != null)
            Image.file(File(_pickedImage!.path), height: 100),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = image;
        _selectedLocalImage = null;
      });
    }
  }

  Future<void> _onSubmit() async {
    if (_addBookFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Indikator loading
        _errorMessage = null; // Reset pesan error
      });

      try {
        // Debugging: Cek nilai yang akan dikirim
        print("Mengirim data buku:");
        print("Judul: ${_judulTextController.text}");
        print("Pengarang: ${_pengarangTextController.text}");
        print("Penerbit: ${_penerbitTextController.text}");
        print("Kategori: ${_kategoriTextController.text}");
        print("Tahun Terbit: ${_tahunTerbitTextController.text}");
        print("Status: $_selectedStatus");
        print("Deskripsi: ${_deskripsiTextController.text}");

        // Kirim data ke server
        String jsonResponse = await ds.insertBuku(
          Config.appid,
          _judulTextController.text,
          _pengarangTextController.text,
          _penerbitTextController.text,
          _kategoriTextController.text,
          _tahunTerbitTextController.text,
          _pickedImage?.path ??
              _selectedLocalImage ??
              '', // Periksa nilai default
          _selectedStatus ?? '', // Periksa apakah null
          _deskripsiTextController.text,
          _dosenPembimbingTextController.text,
          _kodeTextController.text,
        );

        print("Respons JSON: $jsonResponse");

        var decodedResponse = jsonDecode(jsonResponse);

        // Cek apakah respons berupa List dan tidak kosong
        if (decodedResponse is List && decodedResponse.isNotEmpty) {
          // Respons berhasil
          Navigator.pop(context, true);
        } else {
          // Respons kosong atau bukan List
          setState(() {
            _errorMessage = 'Gagal menyimpan data buku.';
          });
        }
      } catch (e) {
        // Tangkap error saat proses
        setState(() {
          _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        });
      } finally {
        // Pastikan loading dihentikan
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDeskripsiField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _deskripsiTextController,
        maxLines: 5,
        validator: (value) => value!.isEmpty ? 'Please enter Deskripsi' : null,
        decoration: InputDecoration(
          labelText: 'Deskripsi',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(color: Colors.blue),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
          ),
        ),
        cursorColor: Colors.blueAccent,
      ),
    );
  }
}
