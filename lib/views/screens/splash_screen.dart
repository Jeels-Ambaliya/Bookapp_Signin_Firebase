import 'dart:async';

import 'package:flutter/material.dart';

class Splah_Screen extends StatefulWidget {
  const Splah_Screen({Key? key}) : super(key: key);

  @override
  State<Splah_Screen> createState() => _Splah_ScreenState();
}

class _Splah_ScreenState extends State<Splah_Screen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacementNamed(context, 'login_page'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.bottomCenter,
        decoration: const BoxDecoration(
          color: Color(0xff1e1e1e),
          image: DecorationImage(
            image: AssetImage("assets/images/book_logo.jpg"),
          ),
        ),
      ),
    );
  }
}
