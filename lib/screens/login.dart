import 'dart:convert';
import 'package:golfr_flutter/main.dart';
import 'package:golfr_flutter/screens/feed.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:golfr_flutter/models/login_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/appbar.dart';

class MyLogin extends StatefulWidget {
  final bool loggedIn;
  final int? id;
  final String? token;
  const MyLogin({Key? key, required this.loggedIn, this.id, this.token})
      : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  late LoginRequest _loginRequest;
  final _formKey = GlobalKey<FormState>();
  late bool _hiddenPassword = true;
  late String error = " ";

  @override
  void initState() {
    super.initState();
    _loginRequest = LoginRequest(email: '', password: '');
  }

  bool _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      return true;
    } else {
      return false;
    }
  }

  void _changeVisibility() {
    setState(() {
      _hiddenPassword = !_hiddenPassword;
    });
  }

  Future<bool?> _loginPost(LoginRequest loginRequest) async {
    final response = await http.post(Uri.http('localhost:3000', 'api/login'),
        body: loginRequest.toJson());
    String responseString = response.body;
    var decodedResponse = jsonDecode(responseString);

    if (response.statusCode == 200) {
      var user = decodedResponse['user'];
      var id = user['id'];
      var token = user['token'];
      error = " ";
      await rememberUser(id, token);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("auth", true);
    }
    if (response.statusCode == 401) {
      var errors = decodedResponse['errors'];
      error = errors.toString();
    }
    return null;
  }

  Future<void> _submit() async {
    if (_saveForm()) {
      await _loginPost(_loginRequest);
      int? id = await getUserId();
      String? token = await getUserToken();
      if (id != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyFeed(id: id, token: token)));
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(children: const [
                  Icon(
                    Icons.report_gmailerrorred,
                    color: Colors.red,
                  ),
                  SizedBox(width: 5),
                  Text('Error'),
                ]),
                content: Text(error),
                actions: [
                  TextButton(onPressed: _closeDialog, child: const Text('Ok')),
                ],
              );
            });
      }
    }
    return;
  }

  void _closeDialog() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loggedIn == true) {
      return MyFeed(id: widget.id, token: widget.token);
    } else {
      return Scaffold(
          appBar: MyAppBar(),
          body: Center(
              child: Container(
                  padding: const EdgeInsets.all(60),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Login", style: TextStyle(fontSize: 35)),
                          const SizedBox(
                            width: 35,
                            height: 35,
                          ),
                          TextFormField(
                              validator: (email) {
                                if (email!.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                if (!email.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              onSaved: (email) => _loginRequest.email = email!,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              )),
                          TextFormField(
                            validator: (password) {
                              if (password!.isEmpty) {
                                return 'Please enter your password';
                              }

                              if (password.length < 6) {
                                return 'Password must have at least 6 characters';
                              }

                              return null;
                            },
                            onSaved: (password) =>
                                _loginRequest.password = password!,
                            decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.password),
                                suffixIcon: _hiddenPassword
                                    ? IconButton(
                                        onPressed: _changeVisibility,
                                        icon: const Icon(Icons.visibility_off),
                                        tooltip: 'Hide password',
                                      )
                                    : IconButton(
                                        onPressed: _changeVisibility,
                                        icon: const Icon(Icons.visibility),
                                        tooltip: 'Show password',
                                      )),
                            obscureText: _hiddenPassword,
                            showCursor: false,
                          ),
                          const SizedBox(
                            width: 35,
                            height: 35,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  shadowColor: Colors.black),
                              onPressed: _submit,
                              child: const Text("Login",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)))
                        ],
                      )))));
    }
  }
}
