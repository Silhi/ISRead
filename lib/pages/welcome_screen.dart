import 'package:flutter/material.dart';

import 'package:isread/pages/login_page.dart';
import 'package:isread/pages/register_page.dart';

import 'package:isread/theme/theme.dart';
import 'package:isread/widgets/custom_scaffold.dart';
import 'package:isread/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hi, Welcome isread!\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      TextSpan(
                        text:
                            '\nBooks are your gateway to endless possibilities. Dive into the world of ideas',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(
                          2), // Adding padding for the border effect
                      child: WelcomeButton(
                        buttonText: 'Sign in',
                        onTap: LoginPage(),
                        color: const Color.fromARGB(0, 255, 255, 255),
                        textColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Added spacing between buttons
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(
                          2), // Adding padding for the border effect
                      child: WelcomeButton(
                        buttonText: 'Sign up',
                        onTap: const RegisterPage(),
                        color: Colors.white,
                        textColor: lightColorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
