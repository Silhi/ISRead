import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isread/pages/home_page.dart';
import 'package:isread/widgets/custom_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set full-screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Fade-in animation for the logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Navigate to the next screen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeView(onCategorySelected: (category) {}),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo with transparent background, no border
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(
                      0), // Removed padding to fit the logo naturally
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                        0.2), // Soft background opacity for blending
                    borderRadius: BorderRadius.circular(0), // No border
                  ),
                  child: Image.asset(
                    'assets/screen/isreadlogo.png',
                    width: 150, // Adjust logo size to make it more fitting
                    height: 150, // Adjust logo size
                  ),
                ),
              ),
              const SizedBox(
                  height: 20), // Adjust spacing between logo and text
              // Elegant, bold tagline text
            ],
          ),
        ),
      ),
    );
  }
}
