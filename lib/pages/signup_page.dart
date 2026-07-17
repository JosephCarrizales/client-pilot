import 'package:client_pilot/pages/home_page.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'First Name',
                        ),
                      ),
                    ),
                    SizedBox(width: 15.0),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Last Name',
                        ),
                      ),
                    ),
                  ],
                ),
            TextFormField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ), 
                SizedBox(height: 50.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, 
                        MaterialPageRoute(
                          builder: (context) {
                            return HomePage();
                          },
                        ),
                      ); 
                    }, 
                    //style: ElevatedButton.styleFrom(
                     // backgroundColor: Colors.blue[900],
                      //foregroundColor: Colors.white,
                   // ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}