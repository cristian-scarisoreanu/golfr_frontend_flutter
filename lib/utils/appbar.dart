import 'package:flutter/material.dart';

class MyAppBar extends AppBar {
  MyAppBar({Key? key, List<Widget>? actions})
      : super(
          key: key,
          actions: actions,
          backgroundColor: Colors.green,
          leading: Image.asset(
            'images/logo.png',
            fit: BoxFit.cover,
            color: Colors.white,
          ),
          centerTitle: false,
          titleSpacing: 0,
          title: const Text(
            "Golfr ",
            style: TextStyle(fontSize: 25),
          ),
        );
}
