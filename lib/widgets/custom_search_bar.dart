/*🔧 Under Design · DotStudios*/

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:elunae/widgets/spinner.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    required this.onSubmitted,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    this.onChanged,
    this.loadingProgressNotifier,
  });

  final Function(String) onSubmitted;
  final ValueNotifier<bool>? loadingProgressNotifier;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final Function(String)? onChanged;

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;

    return Material( // Add Material for elevation + ripple effects if needed
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 55,
          borderRadius: 24,
          blur: 15,
          border: 1,
          alignment: Alignment.center,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              baseColor.withOpacity(0.08),
              baseColor.withOpacity(0.03),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.05),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),

          child: SearchBar(
            hintText: widget.labelText,
            controller: widget.controller,
            focusNode: widget.focusNode,
            textInputAction: TextInputAction.search,
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            onSubmitted: (value) {
              widget.onSubmitted(value);
              widget.focusNode.unfocus();
            },
            onChanged: widget.onChanged != null
                ? (value) async {
              widget.onChanged!(value);
              setState(() {});
            }
                : null,
            trailing: [
              if (widget.loadingProgressNotifier != null)
                ValueListenableBuilder<bool>(
                  valueListenable: widget.loadingProgressNotifier!,
                  builder: (_, value, __) {
                    return IconButton(
                      icon: value
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: Spinner(),
                      )
                          : const Icon(Hicons.search1LightOutline),
                      onPressed: () {
                        widget.onSubmitted(widget.controller.text);
                        widget.focusNode.unfocus();
                      },
                    );
                  },
                )
              else
                IconButton(
                  icon: const Icon(Hicons.search1LightOutline),
                  onPressed: () {
                    widget.onSubmitted(widget.controller.text);
                    widget.focusNode.unfocus();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
