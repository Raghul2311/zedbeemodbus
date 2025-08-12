// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:zedbeemodbus/view_Pages/enter_page.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // loading time
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EnterPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/logo.png", height: 80, fit: BoxFit.cover),
            SpacerWidget.large,
            SizedBox(
              height: 60,
              width: 70,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
