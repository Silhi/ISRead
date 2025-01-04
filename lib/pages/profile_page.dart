import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isread/pages/welcome_page.dart';
import 'package:isread/models/user_model.dart';
import 'package:isread/utils/fire_auth.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfilePage({super.key, this.userData});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;
  UserModel? currentUser;
  bool _isSendingVerification = false;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    processUserData();
  }

  void processUserData() {
    if (widget.userData != null && widget.userData!.isNotEmpty) {
      setState(() {
        currentUser = UserModel.fromJson(widget.userData!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current Firebase user
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display username (or name if it's not set)
            Text(
              'Username: ${currentUser?.username ?? "No username available"}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            // Display NRP (assuming it is part of UserModel)
            Text(
              'NRP: ${currentUser?.nrp ?? "No NRP available"}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            // Display email
            Text(
              'Email: ${currentUser?.email ?? firebaseUser?.email ?? "No email available"}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 16.0),
            _isSigningOut
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isSigningOut = true;
                      });
                      await FirebaseAuth.instance.signOut();
                      setState(() {
                        _isSigningOut = false;
                      });
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Log Out'),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              if (ModalRoute.of(context)?.settings.name != 'home_page') {
                Navigator.pushReplacementNamed(
                  context,
                  'home_page',
                  arguments: widget.userData,
                );
              }
              break;
            case 1: // For Books
              if (ModalRoute.of(context)?.settings.name != 'book_page') {
                Navigator.pushReplacementNamed(
                  context,
                  'book_page',
                  arguments: widget.userData,
                );
              }
              break;
            case 2:
              if (ModalRoute.of(context)?.settings.name != 'scan_page') {
                Navigator.pushReplacementNamed(
                  context,
                  'scan_page',
                  arguments: widget.userData,
                );
              }
              break;
            case 3:
              if (ModalRoute.of(context)?.settings.name != 'profile_page') {
                Navigator.pushReplacementNamed(
                  context,
                  'profile_page',
                  arguments: widget.userData,
                );
              }
              break;
          }
        },
        backgroundColor: const Color(0xff112D4E),
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xffDBE2EF),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
