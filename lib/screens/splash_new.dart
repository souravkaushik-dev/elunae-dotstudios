import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass/liquid_glass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elunae/screens/home_page.dart'; // Preview-only

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _nameController = TextEditingController();
  bool _showTextField = false;

  @override
  @override
  void initState() {
    super.initState();

    // ✅ Initialize animation controller safely here
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _initSplash();
  }

  Future<void> _initSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');

    if (name != null && name.trim().isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) GoRouter.of(context).go('/home');
      return;
    }

    // ✅ Now safely start the animation
    _fadeController.forward();

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _showTextField = true);
  }

  Future<void> _submitName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);

    HapticFeedback.lightImpact();
    if (mounted) GoRouter.of(context).go('/home');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          /// ✅ Blurred preview of home screen
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: const HomePage(), // Only for splash background preview
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),

          /// ✅ Welcome text
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'elunae welcomes you....',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          /// ✅ Skip button
          Positioned(
            top: 40,
            left: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: TextButton(
                onPressed: () => GoRouter.of(context).go('/home'),
                child: Text(
                  'Skip',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),

          /// ✅ Name input
          if (_showTextField)
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: LiquidGlass(
                  opacity: 0.25,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: _nameController,
                      style: GoogleFonts.roboto(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        filled: false, // ❌ Prevent extra background
                        hintText: 'Enter your name',
                        hintStyle: GoogleFonts.roboto(
                          color: Colors.white70,
                        ),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: _submitName,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitName(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
