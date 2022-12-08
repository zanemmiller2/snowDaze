import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'temp_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _password = '';
  String? _email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // for validating the fields
          child: Column(
            //set password
            children: <Widget>[
              const Text(
                'Login Information',
                style: TextStyle(fontSize: 20),
              ),
              TextFormField(
                  onSaved: (value) => _email = value,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(labelText: "Email Address")),
              TextFormField(
                  onSaved: (value) => _password = value.toString(),
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password")),
              ElevatedButton(
                  child: const Text("Login"),
                  onPressed: () async {
                    final form = _formKey.currentState;
                    if (kDebugMode) {
                      print('form: $_formKey');
                    }
                    if (form != null && _email != null && _password != null) {
                      form.save();
                      if (form.validate()) {
                        try {
                          var result = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: _email.toString(),
                                  password: _password.toString());
                          // Ensure the widget is mounted first
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyHomePage(
                                      title: 'snowDaze',
                                    )),
                          );
                        } catch (e) {
                          if (kDebugMode) {
                            print("error");
                          }
                        }
                      }
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
