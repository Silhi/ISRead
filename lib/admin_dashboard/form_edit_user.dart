import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isread/utils/config.dart' as Config;
import 'package:isread/utils/restapi.dart';
import 'package:isread/models/user_model.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({Key? key}) : super(key: key);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final DataService ds = DataService();

  // TextEditingControllers untuk form field
  final _usernameController = TextEditingController();
  final _nrpController = TextEditingController();
  final _emailController = TextEditingController();
  final _noTelponController = TextEditingController();
  final _roleController = TextEditingController();

  String? userId;
  final _editUserFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentPassword;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('userId')) {
      userId = args['userId'] as String?;
      if (userId != null) {
        _fetchUserDetails(); // Ambil detail pengguna berdasarkan userId
      }
    }
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ds.selectId(
        Config.token,
        Config.project,
        'user',
        Config.appid,
        userId!,
      );

      final data = jsonDecode(response);

      if (data is List && data.isNotEmpty) {
        final user = UserModel.fromJson(data[0]);

        setState(() {
          _usernameController.text = user.username ?? '';
          _nrpController.text = user.nrp ?? '';
          _emailController.text = user.email ?? '';
          _currentPassword = user.password; // Simpan password yang ada
          _noTelponController.text = user.no_telpon ?? '';
          _roleController.text = user.role ?? '';
        });
      } else {
        throw Exception('User data not found or empty.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user details: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSubmit() async {
    if (_editUserFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updateStatus = await ds.updateId(
          'username~nrp~email~no_telpon~role',
          '${_usernameController.text}~${_nrpController.text}~${_emailController.text}~${_noTelponController.text}~${_roleController.text}',
          Config.token,
          Config.project,
          'user',
          Config.appid,
          userId!,
        );

        if (updateStatus) {
          Navigator.pop(
              context, true); // Kembali dan beri tahu bahwa data telah diupdate
        } else {
          setState(() {
            _errorMessage =
                'Failed to update user details. Please try again later.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred during the update: $e';
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
      backgroundColor: Colors.white, // Background putih
      appBar: AppBar(
        title: const Text('Edit User', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'manage_user');
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Form(
                  key: _editUserFormKey,
                  child: Column(
                    children: [
                      const Text(
                        'Edit User',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField('Username', _usernameController),
                      _buildTextField('NRP', _nrpController),
                      _buildTextField('Email', _emailController),
                      _buildReadOnlyTextField('Password',
                          '********'), // Tampilkan password dengan aman
                      _buildTextField('No Telpon', _noTelponController),
                      _buildTextField('Role', _roleController),
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
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.grey
                  .withOpacity(0.6)), // Warna label abu dengan opasitas menurun
          border: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.grey), // Ubah border menjadi abu-abu
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.grey), // Ubah border saat fokus menjadi abu-abu
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors
                    .grey), // Ubah border saat tidak fokus menjadi abu-abu
          ),
        ),
        cursorColor: Colors.black,
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildReadOnlyTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.grey
                  .withOpacity(0.6)), // Warna label abu dengan opasitas menurun
          border: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.grey), // Ubah border menjadi abu-abu
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.grey), // Ubah border saat fokus menjadi abu-abu
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors
                    .grey), // Ubah border saat tidak fokus menjadi abu-abu
          ),
        ),
        cursorColor: Colors.black,
      ),
    );
  }
}
