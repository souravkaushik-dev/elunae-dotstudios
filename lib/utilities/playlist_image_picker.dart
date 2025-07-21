/*🔧 Under Design · DotStudios*/

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:elunae/extensions/l10n.dart';

Future<String?> pickImage() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
  );

  if (result != null && result.files.single.bytes != null) {
    final file = result.files.single;
    String? mimeType;

    if (file.extension != null) {
      switch (file.extension!.toLowerCase()) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'bmp':
          mimeType = 'image/bmp';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'application/octet-stream';
      }
    } else {
      mimeType = 'application/octet-stream';
    }

    return 'data:$mimeType;base64,${base64Encode(file.bytes!)}';
  }

  return null;
}

Widget buildImagePreview({
  String? imageBase64,
  String? imageUrl,
  double width = 80,
  double height = 80,
}) {
  if (imageBase64 != null) {
    final base64Data =
        imageBase64.contains(',') ? imageBase64.split(',').last : imageBase64;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Image.memory(
        base64Decode(base64Data),
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  } else if (imageUrl != null && imageUrl.isNotEmpty) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      ),
    );
  }

  return const SizedBox.shrink();
}

Widget buildImagePickerRow(
  BuildContext context,
  Function() onPickImage,
  bool isImagePicked,
) {
  return Row(
    children: [
      ElevatedButton.icon(
        onPressed: onPickImage,
        icon: const Icon(Icons.image),
        label: Text(context.l10n!.pickImageFromDevice),
      ),
      if (isImagePicked)
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
    ],
  );
}
