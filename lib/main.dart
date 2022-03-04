import 'package:flutter/material.dart';
import 'package:golfr_flutter/screens/feed.dart';
import 'package:golfr_flutter/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool("auth") ?? false;
  final id = prefs.getInt("id") ?? -1;
  final token = prefs.getString("token") ?? "x";
  print(loggedIn);
  runApp(MyApp(status: loggedIn, id: id, token: token));
}

Future<void> rememberUser(int id, String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('id', id);
  await prefs.setString('token', token);
}

Future<int?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var id = prefs.getInt("id");
  return id;
}

Future<String?> getUserToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  return token;
}

Future<void> forgetUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("token");
  prefs.remove("id");
  prefs.remove("auth");
}

class MyApp extends StatefulWidget {
  final status;
  final id;
  final token;

  const MyApp(
      {Key? key, required this.status, required this.id, required this.token})
      : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: widget.status
          ? MyFeed(id: widget.id, token: widget.token)
          : const MyLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}
