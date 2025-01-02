import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:isread/utils/fire_auth.dart';
import 'package:isread/utils/validator.dart';
import 'package:flutter/foundation.dart';

import 'package:isread/utils/restapi.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:isread/utils/config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _phoneTextController = TextEditingController();
  final _nrpTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Start your journey\n',
                      style: TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                    TextSpan(
                      text: 'Enter your details to create an account.',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _registerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameTextController,
                      validator: (value) => Validator.validateName(name: value),
                      decoration: const InputDecoration(
                        labelText: "Name",
                        hintText: "Enter your full name",
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blueAccent, width: 2.0),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors
                              .blueAccent, // Warna teks saat label mengambang
                        ),
                      ),
                      cursorColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _nrpTextController,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your NRP' : null,
                      decoration: const InputDecoration(
                        labelText: "NRP",
                        hintText: "Enter your NRP",
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(172, 177, 176, 176),
                              width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blueAccent, width: 2.0),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                      cursorColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailTextController,
                      validator: (value) =>
                          Validator.validateEmail(email: value),
                      decoration: const InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email address",
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blueAccent, width: 2.0),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                      cursorColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _phoneTextController,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          Validator.validatePhoneNumber(value!),
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        hintText: "Enter your phone number",
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blueAccent, width: 2.0),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                      cursorColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordTextController,
                      obscureText: true,
                      validator: (value) =>
                          Validator.validatePassword(password: value),
                      decoration: const InputDecoration(
                        labelText: "Password",
                        hintText: "Enter a strong password",
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blueAccent, width: 2.0),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                      cursorColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_registerFormKey.currentState!.validate()) {
                          bool success = await _registerUser();

                          if (success) {
                            Navigator.pushNamed(context, 'login_page');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Email already exists. Please try a different email.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'login_page');
                      },
                      child: const Text(
                        'Already have an account? Log In',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _registerUser() async {
    try {
      User? firebaseUser = await FireAuth.registerUsingEmailPassword(
        name: _nameTextController.text,
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );

      if (firebaseUser == null) return false;

      final apiResponse = await DataService().insertUser(
        appid,
        _nameTextController.text,
        _nrpTextController.text,
        _emailTextController.text,
        encryptPassword(_passwordTextController.text),
        _phoneTextController.text,
        'mahasiswa',
      );

      if (apiResponse is String) {
        final decodedResponse = jsonDecode(apiResponse);
        if (decodedResponse is List && decodedResponse.isNotEmpty) {
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("Error during registration: $e");
      }
      return false;
    }
  }

  String encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8('1234567890123456');
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);

    return encrypted.base64;
  }
}
