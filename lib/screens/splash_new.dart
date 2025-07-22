import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass/liquid_glass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elunae/screens/home_page.dart'; // Only for preview background

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
  void initState() {
    super.initState();

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

    final selectedAvatar = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAvatarPicker(),
    );

    if (selectedAvatar != null) {
      await prefs.setInt('userAvatar', selectedAvatar);
      if (mounted) GoRouter.of(context).go('/home');
    }
  }

  Widget _buildAvatarPicker() {
    final avatars = [
      'assets/avatars/boy.jpg',
      'assets/avatars/girl.webp',
      'assets/avatars/boy3.gif',
      'assets/avatars/girl2.avif',
      'assets/avatars/girl1.png',
      'assets/avatars/boy2.jpg',
      'assets/avatars/dance.gif',
      'assets/avatars/dance2.gif',
    ];

// Inside your widget builder method:

    return LiquidGlass(
      opacity: 0.25, // Adjust for desired glass opacity
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Remove background color to let glass effect show through
          // color: Colors.black.withOpacity(0.85), // Remove this or keep transparent
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Your Avatar',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: List.generate(avatars.length, (index) {
                return GestureDetector(
                  onTap: () => Navigator.pop(context, index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      avatars[index],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
          /// Background Preview
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: const HomePage(), // preview only
            ),
          ),

          /// Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),

          /// Welcome Text
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

          /// Skip Button
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

          /// Name Input
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
                        filled: false,
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
