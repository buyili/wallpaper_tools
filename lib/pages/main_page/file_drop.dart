import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallpaper_tools/pages/main_page/image_list_widget.dart';
import 'package:wallpaper_tools/providers/file_provider.dart';

import '../../utils/cmd_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/file_utils.dart';

class FileDropWidget extends ConsumerStatefulWidget {
  const FileDropWidget({super.key});

  @override
  ConsumerState<FileDropWidget> createState() => _FileDropWidgetState();
}

class _FileDropWidgetState extends ConsumerState<FileDropWidget> {
  bool _dragging = false;

  // generate magick script
  void _toggleMagickSuffixToJPG() {
    _toggleMagickChangeSuffix("jpg");
  }

  void _toggleMagickSuffixToPNG() {
    _toggleMagickChangeSuffix("png");
  }

  void _toggleMagickChangeSuffix(String suffix) {
    for (var file in ref.read(selectedFilesProvider)) {
      var newFilePath = FileUtils.changeSuffix(file.path, suffix);
      List<String> args = [file.path, newFilePath];
      if (kDebugMode) {
        print("magick ${args.join(" ")}");
      }

      FileUtils.checkFileAndConfirm(
        context,
        newFilePath,
        onConfirmed: () {
          CmdUtils.runCmd("magick", args);
        },
      );
    }
  }

  void magickResizeTo1K(String size) {
    for (var file in ref.read(selectedFilesProvider)) {
      var newFilePath = FileUtils.addSuffixToFileName(file.path, "_1k");
      var args = [file.path, "-resize", size, newFilePath];
      if (kDebugMode) {
        print("magick ${args.join(" ")}");
      }
      FileUtils.checkFileAndConfirm(
        context,
        newFilePath,
        onConfirmed: () {
          CmdUtils.runCmd("magick", args);
        },
      );
    }
  }

  void magickRotate(String rotate) {
    for (var file in ref.read(selectedFilesProvider)) {
      var args = ["convert", "-rotate", rotate, file.path, file.path];
      if (kDebugMode) {
        print("magick ${args.join(" ")}");
      }
      CmdUtils.runCmd("magick", args);
    }
  }

  void _toggleClearAll() {
    ref.read(selectedFilesProvider.notifier).update((state) => []);
  }

  @override
  Widget build(BuildContext context) {
    var selectedFiles = ref.watch(selectedFilesProvider);

    return DropTarget(
      onDragDone: (detail) {
        var files =
            detail.files.where((file) {
              return !ref.read(selectedFilesProvider).any((item) {
                return item.path == file.path;
              });
            }).toList();
        if (files.isEmpty) {
          DialogUtils.showInfoDialog(
            context,
            "No new images were dropped",
            "You can only drop images that are not already selected",
          );
          return;
        }
        ref.read(selectedFilesProvider.notifier).update((state) {
          state.addAll(files);
          return state;
        });
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Selected file size:"),
                    Text(selectedFiles.length.toString()),
                  ],
                ),

                Row(
                  children: [
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed:
                      selectedFiles.isNotEmpty ? _toggleMagickSuffixToPNG : null,
                      child: const Text("Suffix to PNG"),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed:
                          selectedFiles.isNotEmpty ? _toggleMagickSuffixToJPG : null,
                      child: const Text("Suffix to JPG"),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed:
                          (selectedFiles.isNotEmpty) ? _toggleClearAll : null,
                      child: const Text("Clear All"),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              height: 450,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                color:
                    _dragging
                        ? Colors.black26
                        : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
              child:
                  selectedFiles.isEmpty
                      ? const Center(child: Text("Drag and drop images here"))
                      : ImageListWidget(),
            ),

            SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    const Text("Rotate to:"),
                    SizedBox(width: 16),

                    ...["90", "-90", "180", "-180"]
                        .map(
                          (rotate) => [
                            FilledButton(
                              onPressed:
                                  selectedFiles.isNotEmpty
                                      ? () {
                                        magickRotate(rotate);
                                      }
                                      : null,
                              child: Text(rotate),
                            ),
                            SizedBox(width: 16),
                          ],
                        )
                        .expand((e) => e),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Text("Resize to:"),
                    SizedBox(width: 16),

                    ...['1920x', 'x1080', '1080x', 'x1920']
                        .map(
                          (rotate) => [
                            FilledButton(
                              onPressed:
                                  selectedFiles.isNotEmpty
                                      ? () {
                                        magickResizeTo1K(rotate);
                                      }
                                      : null,
                              child: Text(rotate),
                            ),
                            SizedBox(width: 16),
                          ],
                        )
                        .expand((e) => e),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
