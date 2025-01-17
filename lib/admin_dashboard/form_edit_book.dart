import 'package:flutter/material.dart';
import 'package:isread/utils/config.dart' as Config;
import 'package:isread/utils/restapi.dart';
import 'package:isread/models/book_model.dart';

class EditBookPage extends StatefulWidget {
  final BukuModel book;

  const EditBookPage({Key? key, required this.book}) : super(key: key);

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final DataService ds = DataService();

  // Controllers
  final _controllers = {
    'judul': TextEditingController(),
    'pengarang': TextEditingController(),
    'penerbit': TextEditingController(),
    'kategori': TextEditingController(),
    'tahun': TextEditingController(),
    'deskripsi': TextEditingController(),
    'kodeBuku': TextEditingController(),
    'dosenPembimbing': TextEditingController(),
  };

  final _statusOptions = ['Tersedia', 'Dipinjam'];
  String? _selectedStatus;
  final _editBookFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _controllers['judul']!.text = widget.book.judul_buku ?? '';
    _controllers['pengarang']!.text = widget.book.pengarang ?? '';
    _controllers['penerbit']!.text = widget.book.penerbit ?? '';
    _controllers['kategori']!.text = widget.book.kategori_buku ?? '';
    _controllers['tahun']!.text = widget.book.tahun_terbit?.toString() ?? '';
    _controllers['deskripsi']!.text = widget.book.deskripsi ?? '';
    _controllers['kodeBuku']!.text = widget.book.kode_buku ?? '';
    _controllers['dosenPembimbing']!.text = widget.book.dosen_pembimbing ?? '';
    _selectedStatus = widget.book.status;
  }

  Future<void> _onSubmit() async {
    if (_editBookFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updateStatus = await ds.updateId(
          'judul_buku~pengarang~penerbit~kategori_buku~tahun_terbit~deskripsi~status~sampul_buku~dosen_pembimbing~kode_buku',
          '${_controllers['judul']!.text}~${_controllers['pengarang']!.text}~${_controllers['penerbit']!.text}~${_controllers['kategori']!.text}~${_controllers['tahun']!.text}~${_controllers['deskripsi']!.text}~$_selectedStatus~${widget.book.sampul_buku}~${_controllers['dosenPembimbing']!.text}~${_controllers['kodeBuku']!.text}',
          Config.token,
          Config.project,
          'buku',
          Config.appid,
          widget.book.id,
        );

        if (updateStatus) {
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
        title: const Text('Edit Book', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
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
              ..._buildFormFields(),
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
    );
  }

  List<Widget> _buildFormFields() {
    return [
      _buildTextField('Judul Buku', _controllers['judul']!),
      _buildTextField('Pengarang', _controllers['pengarang']!),
      _buildTextField('Penerbit', _controllers['penerbit']!),
      _buildTextField('Kategori', _controllers['kategori']!),
      _buildTextField('Tahun Terbit', _controllers['tahun']!,
          keyboardType: TextInputType.number),
      _buildReadOnlyField('Sampul Buku', widget.book.sampul_buku),
      _buildDropdown(),
      _buildDeskripsiField(),
      _buildTextField('Dosen Pembimbing', _controllers['dosenPembimbing']!),
      _buildTextField('Kode Buku', _controllers['kodeBuku']!),
    ];
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label),
        cursorColor: Colors.black,
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: _inputDecoration(label),
        cursorColor: Colors.black,
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedStatus,
        decoration: _inputDecoration('Status'),
        dropdownColor: Colors.white, // Setting the dropdown background color
        items: _statusOptions
            .map((status) =>
                DropdownMenuItem(value: status, child: Text(status)))
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
        controller: _controllers['deskripsi']!,
        maxLines: 3,
        decoration: _inputDecoration('Deskripsi'),
        cursorColor: Colors.black,
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter a description' : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
          color: Colors.blueAccent), // Change label color to blue
      fillColor: Colors.white, // Set the background color
      filled: true,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        borderSide: BorderSide(color: Colors.blueAccent),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent),
      ),
    );
  }
}
