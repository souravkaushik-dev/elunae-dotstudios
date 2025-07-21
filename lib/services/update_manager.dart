/*🔧 Under Design · DotStudios*/

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:elunae/API/version.dart';
import 'package:elunae/extensions/l10n.dart';
import 'package:elunae/main.dart';
import 'package:elunae/services/router_service.dart';
import 'package:elunae/services/settings_manager.dart';
import 'package:elunae/utilities/url_launcher.dart';
import 'package:elunae/widgets/auto_format_text.dart';

const String checkUrl =
    'https://raw.githubusercontent.com/gokadzev/elunae/update/check.json';
const String releasesUrl =
    'https://api.github.com/repos/gokadzev/elunae/releases/latest';
const String downloadUrlKey = 'url';
const String downloadUrlArm64Key = 'arm64url';
const String downloadFilename = 'elunae.apk';

Future<void> checkAppUpdates() async {
  try {
    final response = await http.get(Uri.parse(checkUrl));

    if (response.statusCode != 200) {
      logger.log(
        'Fetch update API (checkUrl) call returned status code ${response.statusCode}',
        null,
        null,
      );
      return;
    }

    final map = json.decode(response.body) as Map<String, dynamic>;
    announcementURL.value = map['announcementurl'];
    final latestVersion = map['version'].toString();

    if (!isLatestVersionHigher(appVersion, latestVersion)) {
      return;
    }

    final releasesRequest = await http.get(Uri.parse(releasesUrl));

    if (releasesRequest.statusCode != 200) {
      logger.log(
        'Fetch update API (releasesUrl) call returned status code ${response.statusCode}',
        null,
        null,
      );
      return;
    }

    final releasesResponse =
        json.decode(releasesRequest.body) as Map<String, dynamic>;

    await showDialog(
      context: NavigationManager().context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n!.appUpdateIsAvailable,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'V$latestVersion',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height / 2.14,
                ),
                child: SingleChildScrollView(
                  child: AutoFormatText(text: releasesResponse['body']),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(context.l10n!.cancel.toUpperCase()),
            ),
            FilledButton(
              onPressed: () {
                getDownloadUrl(map).then(
                  (url) => {launchURL(Uri.parse(url)), Navigator.pop(context)},
                );
              },
              child: Text(context.l10n!.download.toUpperCase()),
            ),
          ],
        );
      },
    );
  } catch (e, stackTrace) {
    logger.log('Error in checkAppUpdates', e, stackTrace);
  }
}

bool isLatestVersionHigher(String appVersion, String latestVersion) {
  final parsedAppVersion = appVersion.split('.');
  final parsedAppLatestVersion = latestVersion.split('.');
  final length =
      parsedAppVersion.length > parsedAppLatestVersion.length
          ? parsedAppVersion.length
          : parsedAppLatestVersion.length;
  for (var i = 0; i < length; i++) {
    final value1 =
        i < parsedAppVersion.length ? int.parse(parsedAppVersion[i]) : 0;
    final value2 =
        i < parsedAppLatestVersion.length
            ? int.parse(parsedAppLatestVersion[i])
            : 0;
    if (value2 > value1) {
      return true;
    } else if (value2 < value1) {
      return false;
    }
  }

  return false;
}

Future<String> getCPUArchitecture() async {
  final info = await Process.run('uname', ['-m']);
  final cpu = info.stdout.toString().replaceAll('\n', '');

  return cpu;
}

Future<String> getDownloadUrl(Map<String, dynamic> map) async {
  final cpuArchitecture = await getCPUArchitecture();
  final url =
      cpuArchitecture == 'aarch64'
          ? map[downloadUrlArm64Key].toString()
          : map[downloadUrlKey].toString();

  return url;
}
