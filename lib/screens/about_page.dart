import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'About',
                style: GoogleFonts.sora(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildGlassCard(
                    title: 'DotStudios',
                    description:
                    'DotStudios (previously known as Envior Studios) is currently running as an individual app development and design studio. It focuses on building new UI concepts, customizing app experiences, and crafting new apps daily — all to make your digital experience more fluid and frequent.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildGlassCard(
                    title: 'Elunae',
                    description:
                    'Elunae is designed with iOS-style UI and SDKs. It is currently in the testing phase and may contain some bugs. Elunae is a refined and reimagined version of the elunae app (available on GitHub), and was previously known as Dottunes.',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required String description,
    required bool isDark,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 313,
      borderRadius: 24,
      blur: 20,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: LinearGradient(
        colors: isDark
            ? [
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.02),
        ]
            : [
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.sora(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
