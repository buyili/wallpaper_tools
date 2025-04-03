import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wallpaper_tools/utils/cmd_utils.dart';
import 'package:wallpaper_tools/utils/file_utils.dart';

import '../utils/dialog_utils.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // selected apk files
  final List<XFile> _selectedFileList = [];
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // generate magick script
  void onGenerateMagickScript() {
    var outText = _selectedFileList
        .map((file) {
          return "magick ${file.name} ${file.name}.jpg";
        })
        .toList()
        .join("\n");
    copyToClipboard(outText);
  }

  // clear all apk files
  void onClearAll() {
    setState(() {
      _selectedFileList.clear();
    });
  }

  void copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    // 可选：显示一个提示给用户，告诉他们文本已经被复制
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text("Text copied to clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FileDropWidget(
                  list: _selectedFileList,
                  onGenerateMagickScript: onGenerateMagickScript,
                  onClearAll: onClearAll,
                ),

                SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    // Take a photo and save it to the device
                    String photoName = generatePhotoName();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Photo saved as $photoName")),
                    );
                  },
                  child: Text("Take a photo"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FileDropWidget extends StatefulWidget {
  final List<XFile> list;
  final Function() onGenerateMagickScript;
  final Function() onClearAll;

  const FileDropWidget({
    super.key,
    required this.list,
    required this.onGenerateMagickScript,
    required this.onClearAll,
  });

  @override
  State<FileDropWidget> createState() => _FileDropWidgetState();
}

class _FileDropWidgetState extends State<FileDropWidget> {
  bool _dragging = false;

  void magickResizeTo1K(String size) {
    for (var file in widget.list) {
      var args = [
        file.path,
        "-resize",
        size,
        FileUtils.addSuffixToFileName(file.path, "_1k"),
      ];
      if (kDebugMode) {
        print("magick ${args.join(" ")}");
      }
      CmdUtils.runCmd("magick", args);
    }
  }

  void magickRotate(String rotate) {
    for (var file in widget.list) {
      var args = ["convert", "-rotate", rotate, file.path, file.path];
      if (kDebugMode) {
        print("magick ${args.join(" ")}");
      }
      CmdUtils.runCmd("magick", args);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) {
        var files =
            detail.files.where((file) {
              return !widget.list.any((item) {
                return item.path == file.path;
              });
            }).toList();
        if (files.isEmpty) {
          DialogUtils.showInfoDialog(
            context,
            "No new APK files were dropped",
            "You can only drop APK files that are not already selected",
          );
          return;
        }
        setState(() {
          widget.list.addAll(files);
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
                    Text(widget.list.length.toString()),
                  ],
                ),

                Row(
                  children: [
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed:
                          widget.list.isNotEmpty
                              ? widget.onGenerateMagickScript
                              : null,
                      child: const Text("Generate Magick Script"),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed:
                          (widget.list.isNotEmpty) ? widget.onClearAll : null,
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
                  widget.list.isEmpty
                      ? const Center(
                        child: Text("Drag and drop APK or other files here"),
                      )
                      : ListView.builder(
                        itemCount: widget.list.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 10.0,
                              top: 8.0,
                              right: 8,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.android),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(widget.list[index].name),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            widget.list.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),

            SizedBox(height: 16),
            Row(
              children: [
                const Text("Rotate to:"),
                SizedBox(width: 16),

                FilledButton(
                  onPressed:
                      widget.list.isNotEmpty
                          ? () {
                            magickRotate("90");
                          }
                          : null,
                  child: Text("90"),
                ),

                SizedBox(width: 16),

                FilledButton(
                  onPressed:
                      widget.list.isNotEmpty
                          ? () {
                            magickRotate("-90");
                          }
                          : null,
                  child: Text("-90"),
                ),

                SizedBox(width: 16),

                FilledButton(
                  onPressed:
                      widget.list.isNotEmpty
                          ? () {
                            magickRotate("180");
                          }
                          : null,
                  child: Text("180"),
                ),

                const Spacer(),
                const Text("Resize to:"),
                SizedBox(width: 16),

                FilledButton(
                  onPressed:
                      widget.list.isNotEmpty
                          ? () {
                            magickResizeTo1K("1920");
                          }
                          : null,
                  child: Text("1920x"),
                ),

                SizedBox(width: 16),

                FilledButton(
                  onPressed:
                      widget.list.isNotEmpty
                          ? () {
                            magickResizeTo1K("x1080");
                          }
                          : null,
                  child: Text("x1080"),
                ),

                SizedBox(width: 16),

                FilledButton(
                  onPressed:
                      widget.list.isNotEmpty
                          ? () {
                            magickResizeTo1K("1080");
                          }
                          : null,
                  child: Text("1080x"),
                ),
                SizedBox(width: 16),

                FilledButton(
                  onPressed:
                      widget.list.isNotEmpty
                          ? () {
                            magickResizeTo1K("x1920");
                          }
                          : null,
                  child: Text("x1920"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String generatePhotoName() {
  var now = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd_HH-mm-ss');
  String formattedTime = formatter.format(now);
  return "photo_$formattedTime";
}
