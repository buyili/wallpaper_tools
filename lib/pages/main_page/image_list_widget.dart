import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallpaper_tools/pages/main_page/thumbnail_widget.dart';
import 'package:wallpaper_tools/providers/file_provider.dart';

class ImageListWidget extends ConsumerWidget {
  const ImageListWidget({super.key});

  void _toggleDelete(int index, WidgetRef ref) {
    ref.read(selectedFilesProvider.notifier).update((files) {
      files.removeAt(index);
      return [...files];
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFiles = ref.watch(selectedFilesProvider);

    return ListView.builder(
      itemCount: selectedFiles.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 8.0, right: 12.0),
          child: Row(
            children: [
              ThumbnailWidget(thumbnailUrl: selectedFiles[index].path),

              const SizedBox(width: 10),

              Expanded(child: Row(children: [Text(selectedFiles[index].name)])),

              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _toggleDelete(index, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
