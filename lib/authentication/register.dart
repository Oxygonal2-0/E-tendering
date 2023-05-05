import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pritam_app/authentication/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _name;
  late String _phone;
  late String _email;
  late String _pass;
  late String _cpass;

  Future registration(context) async {
    if (_pass == _cpass) {
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _pass);

        UserCredential user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _pass);
        user.user?.updateDisplayName(_name);
        user.user?.updatePhotoURL(_phone);

        // print(userCredential.user?.phoneNumber);
        // print(userCredential.user?.displayName);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registraion Successful'),
          backgroundColor: Colors.green,
        ));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('WeakPassword')));
        }
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email id already Exist')));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red[400],
          content: const Text('Password and Confirm password doesnot match')));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 25),
            child: ListView(
              padding: const EdgeInsets.only(
                  top: 20, left: 10, bottom: 10, right: 10),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'E-Tendering',
                            style: TextStyle(
                                color: Colors.lightBlue[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 30),
                          )),
                      Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 20),
                          )),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Name',
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Name is Required';
                            }
                            return null;
                          },
                          onSaved: (String? value) {
                            _name = value!;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Mobile No.',
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Mobile No is Required';
                            } else if (value.length != 10) {
                              return 'Enter 10 digit Mobile No.';
                            }
                            return null;
                          },
                          onSaved: (String? value) {
                            _phone = value!;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Email is Required';
                            } else if (!RegExp(
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                .hasMatch(value)) {
                              return 'Please Enter Valid Email Address';
                            }
                            return null;
                          },
                          onSaved: (String? value) {
                            _email = value!;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Password is Required';
                            }
                            return null;
                          },
                          onSaved: (String? value) {
                            _pass = value!;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Confirm Password',
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Password is Required';
                            }
                            return null;
                          },
                          onSaved: (String? value) {
                            _cpass = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        _formKey.currentState!.save();
                        registration(context);
                      },
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Already have an Account   '),
                    TextButton(
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
