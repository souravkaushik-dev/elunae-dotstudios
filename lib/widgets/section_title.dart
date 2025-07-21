/*🔧 Under Design · DotStudios*/

import 'package:flutter/material.dart';
import 'package:elunae/widgets/marque.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, this.primaryColor, {super.key});
  final Color primaryColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.7,
          child: MarqueeWidget(
            child: Text(
              title,
              style: TextStyle(
                color: primaryColor,
                fontSize:
                    Theme.of(context).textTheme.titleMedium?.fontSize ?? 16,
                fontFamily: 'regular',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
