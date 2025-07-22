import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionSpinner extends StatefulWidget {
  const VersionSpinner({super.key});

  @override
  State<VersionSpinner> createState() => _VersionSpinnerState();
}

class _VersionSpinnerState extends State<VersionSpinner> {
  final Random _random = Random();
  late Timer _timer;
  String _displayVersion = "v0.0.0";
  String _realVersion = "v1.0.0"; // fallback

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _startFastSpin();
  }

  void _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    _realVersion = "v${info.version}";
  }

  void _startFastSpin() {
    int count = 0;
    _timer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (count > 25) { // ~500ms spin
        timer.cancel();
        setState(() => _displayVersion = _realVersion);
      } else {
        setState(() {
          _displayVersion = "v${_random.nextInt(10)}.${_random.nextInt(10)}.${_random.nextInt(10)}";
        });
        count++;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack), child: child),
      child: Text(
        _displayVersion,
        key: ValueKey(_displayVersion), // Required for AnimatedSwitcher to detect changes
        style: TextStyle(
          fontFamily: 'displaymedium',
          fontSize: 12,
          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
        ),
      ),
    );
  }
}
