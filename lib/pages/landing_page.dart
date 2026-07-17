import 'package:client_pilot/pages/login_page.dart';
import 'package:client_pilot/pages/signup_page.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top spacing
                const SizedBox(height: 20),

                // Logo + title
                Column(
                  children: [
                    // Placeholder circle logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Client Pilot',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Smart CRM & AI automation\nfor businesses.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        //color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context, MaterialPageRoute(
                            builder: (context) {
                              return LoginPage();
                            },
                          ),
                        );
                      },
                      //style: ElevatedButton.styleFrom(
                       // backgroundColor: Colors.blue[900],
                        //foregroundColor: Colors.white,
                      //),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Text(
                          'Log In',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Navigate to sign up screen
                        // Navigator.pushNamed(context, '/signup');
                        Navigator.push(
                          context, MaterialPageRoute(
                            builder: (context) {
                              return SignupPage();
                            },
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'By continuing, you agree to our Terms & Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                       // color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}