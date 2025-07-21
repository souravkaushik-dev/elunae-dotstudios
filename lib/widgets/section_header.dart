/*🔧 Under Design · DotStudios*/

import 'package:flutter/material.dart';
import 'package:elunae/widgets/section_title.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionButton});
  final String title;
  final Widget? actionButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SectionTitle(title, Theme.of(context).colorScheme.primary),
        ),
        if (actionButton != null) actionButton!,
      ],
    );
  }
}
