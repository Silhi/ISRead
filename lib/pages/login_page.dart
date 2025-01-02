import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:isread/pages/home_view.dart';

import 'package:isread/utils/config.dart' as configUser;
import 'package:isread/admin_dashboard/book_dashboard.dart';
import 'package:isread/utils/validator.dart';
import 'package:isread/widgets/custom_scaffold.dart';
import '../theme/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;
  bool rememberPassword = false;

  @override
  void dispose() {
    _emailTextController.dispose();
    _passwordTextController.dispose();
    _focusEmail.dispose();
    _focusPassword.dispose();
    super.dispose();
  }

  Future<String?> fetchUserRole(String email) async {
    final url =
        'https://io.etter.cloud/v4/select_all/token/${configUser.token}/project/${configUser.project}/collection/user/appid/${configUser.appid}?email=$email';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        // Cari user dengan email yang cocok
        final user = responseData.firstWhere(
          (user) => user['email'] == email,
          orElse: () => null,
        );

        if (user != null) {
          return user['role'];
        } else {
          debugPrint('User with email $email not found.');
          return null;
        }
      } else {
        debugPrint('Failed to fetch role: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  void handleLogin(User user) async {
    final role = await fetchUserRole(
        user.email!); // Ambil role menggunakan email Firebase

    if (role != null) {
      if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BookDashboard(),
          ),
        );
      } else if (role == 'mahasiswa') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeView(onCategorySelected: (category) {}),
          ),
        );
      } else {
        _showSnackBar('Role tidak dikenali: $role');
      }
    } else {
      _showSnackBar('Gagal mengambil data role pengguna');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w800,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'Please log in to your account',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      TextFormField(
                        controller: _emailTextController,
                        focusNode: _focusEmail,
                        validator: (value) =>
                            Validator.validateEmail(email: value),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          floatingLabelStyle: TextStyle(
                            color: lightColorScheme
                                .primary, // Warna label saat mengambang
                            fontWeight: FontWeight
                                .w600, // Ketebalan teks agar lebih jelas
                          ),
                          hintText: 'Enter your email',
                          hintStyle: const TextStyle(color: Colors.black38),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey
                                  .shade400, // Warna border saat tidak fokus
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: lightColorScheme
                                  .primary, // Warna border saat fokus
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors
                                  .red.shade400, // Warna border saat ada error
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red
                                  .shade600, // Warna border error saat fokus
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        cursorColor: Colors.blueAccent,
                      ),
                      const SizedBox(height: 18.0),
                      TextFormField(
                        controller: _passwordTextController,
                        focusNode: _focusPassword,
                        obscureText: true, // Menyembunyikan input password
                        validator: (value) =>
                            Validator.validatePassword(password: value),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          floatingLabelStyle: TextStyle(
                            color: lightColorScheme
                                .primary, // Warna label saat mengambang
                            fontWeight: FontWeight
                                .w600, // Ketebalan teks agar lebih jelas
                          ),
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(color: Colors.black38),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey
                                  .shade400, // Warna border saat tidak fokus
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: lightColorScheme
                                  .primary, // Warna border saat fokus
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors
                                  .red.shade400, // Warna border saat ada error
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red
                                  .shade600, // Warna border error saat fokus
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        cursorColor: Colors.blueAccent,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Tambahkan logika untuk Forgot Password
                            print('Forgot Password clicked');
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            backgroundColor: lightColorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            _focusEmail.unfocus();
                            _focusPassword.unfocus();

                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isProcessing = true;
                              });

                              try {
                                UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                  email: _emailTextController.text,
                                  password: _passwordTextController.text,
                                );

                                setState(() {
                                  _isProcessing = false;
                                });

                                handleLogin(userCredential.user!);
                              } catch (e) {
                                setState(() {
                                  _isProcessing = false;
                                });
                                _showSnackBar('Login gagal: ${e.toString()}');
                              }
                            }
                          },
                          child: _isProcessing
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1.0,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'or login with',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon:
                                const Icon(Icons.facebook, color: Colors.blue),
                            onPressed: () {
                              // Tambahkan logika untuk login dengan Facebook
                              print('Login with Facebook');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.alternate_email,
                                color: Colors.blueAccent),
                            onPressed: () {
                              // Tambahkan logika untuk login dengan Google
                              print('Login with Google');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.apple, color: Colors.black),
                            onPressed: () {
                              // Tambahkan logika untuk login dengan Apple
                              print('Login with Apple');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
