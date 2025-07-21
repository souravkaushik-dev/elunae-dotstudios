import 'package:flutter/cupertino.dart';
import 'package:elunae/main.dart';
import 'package:elunae/screens/splash_new.dart';

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    await initialisation(); // your existing function
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? const elunae()
        : const SplashScreen(); // your custom splash screen widget
  }
}
