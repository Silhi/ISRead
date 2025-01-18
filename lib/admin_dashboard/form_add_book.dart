import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isread/utils/restapi.dart';
import 'package:isread/utils/config.dart';
import 'package:isread/models/book_model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _addBookFormKey = GlobalKey<FormState>();

  DataService ds = DataService();

  List<BukuModel> buku = [];

  final _judulTextController = TextEditingController();
  final _pengarangTextController = TextEditingController();
  final _penerbitTextController = TextEditingController();
  final _tahunTerbitTextController = TextEditingController();
  final _deskripsiTextController = TextEditingController();
  final _dosenPembimbingTextController = TextEditingController();
  final _kodeTextController = TextEditingController();

  String? _selectedCategory;
  String? _selectedStatus;
  String? _selectedLocalImage;
  String? _errorMessage;
  File? _pickedImage;
  Uint8List? _pickedImageBytes;
  XFile? imageFile;

  String sampul_buku = '';
  List<BukuModel> book = [];
  List data = [];
  bool _isLoading = false;

  final List<String> _statusOptions = ['Tersedia', 'Dipinjam'];

  final List<String> _categories = [
    'Tugas Akhir',
    'Skripsi',
    'Laporan Praktik Kerja',
    'Laporan Akhir MBKM',
    'Umum'
  ];

  final List<String> _localImages = [
    'assets/sampul/Laporan Akhir MBKM.jpeg',
    'assets/sampul/Laporan Praktik Kerja.jpeg',
    'assets/sampul/Sistem Informasi Perusahaan.jpeg',
    'assets/sampul/Tugas Akhir.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _kodeTextController.text = '';
    _penerbitTextController.addListener(generateAutomaticCodes);
  }

  @override
  void dispose() {
    _penerbitTextController.removeListener(generateAutomaticCodes);
    _judulTextController.dispose();
    _pengarangTextController.dispose();
    _penerbitTextController.dispose();
    _tahunTerbitTextController.dispose();
    _deskripsiTextController.dispose();
    _dosenPembimbingTextController.dispose();
    _kodeTextController.dispose();
    super.dispose();
  }

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
                _buildTextField('NRP Penulis', _penerbitTextController,
                    hintText: 'Format: 162022XXX'),
                _buildCategoryDropdown(),
                _buildYearField(),
                _buildImagePicker(),
                _buildDropdown(),
                _buildDeskripsiField(),
                _buildTextField(
                    'Dosen Pembimbing', _dosenPembimbingTextController,
                    hintText: 'Jika tidak ada maka diisi -'),
                _buildTextField('Kode Buku', _kodeTextController,
                    hintText: 'Auto generate', enabled: false),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 30.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: const Text('Add Book',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Kategori Buku',
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
        dropdownColor: Colors.white,
        value: _selectedCategory,
        items: _categories
            .map((category) =>
                DropdownMenuItem(value: category, child: Text(category)))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
            print("Selected category: $_selectedCategory");
            generateAutomaticCodes();
          });
        },
        validator: (value) => value == null ? 'Please select a category' : null,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      String? hintText,
      bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        cursorColor: Colors.blueAccent,
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: const TextStyle(color: Colors.blue),
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 1.5)),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 1.0)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue, width: 2.0)),
        ),
      ),
    );
  }

  Widget _buildYearField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          // Memunculkan date picker hanya untuk tahun
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900), // Tahun pertama yang bisa dipilih
            lastDate: DateTime.now(), // Tahun terakhir yang bisa dipilih
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: Colors.blue, // Warna utama
                  colorScheme: ColorScheme.light(
                    primary:
                        Colors.blue, // Menggunakan primary sebagai warna utama
                    secondary:
                        Colors.blue, // Ganti accentColor dengan secondary
                  ),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            // Ambil tahun dari tanggal yang dipilih
            _tahunTerbitTextController.text = pickedDate.year.toString();
          }
        },
        child: AbsorbPointer(
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
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul untuk memilih gambar
          Text(
            'Pilih Sampul Buku',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Dropdown untuk memilih sampul buku dari lokal
          DropdownButton<String>(
            dropdownColor: Colors.white,
            hint: const Text('Pilih Sampul Buku'),
            value: _selectedLocalImage,
            isExpanded: true,
            items: _localImages.map((path) {
              return DropdownMenuItem(
                value: path,
                child: Row(
                  children: [
                    Image.asset(
                      path,
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _getFileNameWithoutExtension(path),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLocalImage = value;
                sampul_buku =
                    value ?? ''; // Tetapkan jalur lokal ke sampul_buku
                _pickedImage = null;
                _pickedImageBytes = null;
              });
            },
          ),
          const SizedBox(height: 16),

          // Tombol untuk upload gambar
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Pilih Gambar'),
          ),
          const SizedBox(height: 8),

          // Tampilkan status file yang berhasil diunggah
          if (sampul_buku != null && sampul_buku!.isNotEmpty)
            Text(
              'Submitted File: $sampul_buku',
              style: const TextStyle(color: Colors.green),
            ),

          // Tampilkan pesan error jika ada
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

// Fungsi untuk mengambil nama file tanpa ekstensi
  String _getFileNameWithoutExtension(String filePath) {
    return filePath.split('/').last.split('.').first;
  }

  Future<void> selectIdbook(String id) async {
    try {
      data = jsonDecode(await ds.selectId(token, project, 'buku', appid, id));
      book = data.map((e) => BukuModel.fromJson(e)).toList();
      sampul_buku = book[0].sampul_buku;
    } catch (e) {
      print('Error loading book data: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      var picked = await FilePicker.platform.pickFiles(withData: true);
      if (picked != null) {
        var response = await ds.upload(
          token,
          project,
          picked.files.first.bytes!,
          picked.files.first.extension.toString(),
        );
        var file = jsonDecode(response);
        setState(() {
          sampul_buku = file['file_name']; // Update sampul_buku
          _selectedLocalImage = null; // Hapus pilihan gambar lokal
          _errorMessage = null; // Hapus pesan error jika sebelumnya ada
        });
      } else {
        setState(() {
          _errorMessage =
              "Tidak ada gambar yang dipilih"; // Tampilkan error jika batal memilih
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = "Gagal memilih gambar: ${e.message}";
      });
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<List<BukuModel>> selectAllBuku() async {
    final String jsonResponse =
        await ds.selectAll(token, project, 'buku', appid);
    final List data = jsonDecode(jsonResponse);
    return data.map((e) => BukuModel.fromJson(e)).toList();
  }

  Future<void> selectAllBukuAndUpdateState() async {
    try {
      final allBuku = await selectAllBuku();
      setState(() {
        buku = allBuku;
      });
    } catch (e) {
      print("Error fetching books: $e");
    }
  }

  Future<int> countBooksByCategory(String category) async {
    final String jsonResponse = await ds.selectWhere(
      token,
      project,
      'buku',
      appid,
      'kategori_buku',
      category,
    );

    final List data = jsonDecode(jsonResponse);

    int maxCode = 0;

    for (var item in data) {
      final String kodeBuku = item['kode_buku'];
      if (kodeBuku.isNotEmpty) {
        var parts = kodeBuku.split('-');
        if (parts.length > 1) {
          var urutan = int.tryParse(parts[1]);
          if (urutan != null && urutan > maxCode) {
            maxCode = urutan;
          }
        }
      }
    }

    return maxCode;
  }

  Future<void> generateAutomaticCodes() async {
    if (_penerbitTextController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? kodePrefix;
      switch (_selectedCategory) {
        case 'Tugas Akhir':
          kodePrefix = 'TA';
          break;
        case 'Skripsi':
          kodePrefix = 'SK';
          break;
        case 'Laporan Praktik Kerja':
          kodePrefix = 'KP';
          break;
        case 'Laporan Akhir MBKM':
          kodePrefix = 'MBKM';
          break;
        case 'Umum':
          kodePrefix = 'BK';
          break;
        default:
          return;
      }

      int existingCount = await countBooksByCategory(_selectedCategory!);
      final String urutan = (existingCount + 1).toString().padLeft(3, '0');

      String newKode;

      if (_selectedCategory == 'Umum') {
        // Hanya menampilkan prefix dan urutan untuk kategori Umum
        newKode = '$kodePrefix-$urutan';
      } else {
        // Ambil kode penerbit untuk kategori lainnya
        final String penerbitCode =
            _penerbitTextController.text.substring(2, 6) +
                '-' +
                _penerbitTextController.text.substring(6);
        newKode = '$kodePrefix-$urutan-$penerbitCode';
      }
      _kodeTextController.text = newKode; // Set the generated code in the field

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generated code: $newKode')),
      );
    } catch (e) {
      print("Error generating book code: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addBook() async {
    if (_kodeTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate the code first')),
      );
      return;
    }

    // Continue with adding the book logic here...
    print("Book added with code: ${_kodeTextController.text}");
  }

  Future<void> _onSubmit() async {
    if (_addBookFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (_selectedCategory == null || _selectedStatus == null) {
        setState(() {
          _errorMessage = 'Please select category and status';
        });
        return;
      }

      if (sampul_buku.isEmpty) {
        setState(() {
          _errorMessage = 'Harap pilih sampul buku terlebih dahulu.';
        });
        return;
      }

      // Submit book data
      try {
        String jsonResponse = await ds.insertBuku(
          appid,
          _judulTextController.text,
          _pengarangTextController.text,
          _penerbitTextController.text,
          _selectedCategory!,
          _tahunTerbitTextController.text,
          sampul_buku,
          _selectedStatus!,
          _deskripsiTextController.text,
          _dosenPembimbingTextController.text,
          _kodeTextController.text,
        );

        // Handle the response
        var decodedResponse = jsonDecode(jsonResponse);
        if (decodedResponse is List && decodedResponse.isNotEmpty) {
          // Data berhasil ditambahkan
          Navigator.pop(context, true); // Kembali ke dashboard
        } else {
          setState(() {
            _errorMessage = 'Format respons tidak sesuai atau data kosong.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        });
      } finally {
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
