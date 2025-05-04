import 'dart:io';
import 'package:flutter/material.dart';

class ThumbnailWidget extends StatelessWidget {
  final String thumbnailUrl;
  const ThumbnailWidget({super.key, required this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 80,
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.file(File(thumbnailUrl)),
          ),
        ),
      ),
    );
  }
}
