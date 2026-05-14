import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final File image;

  const ImagePreview({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        image,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}