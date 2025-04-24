import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'main_page/file_drop.dart';


var pattern1 = 'yyyy-MM-dd_HH-mm-ss';
var pattern2 = 'yyyyMMdd-HHmmss';

String generatePhotoName(String pattern) {
  var now = DateTime.now();
  var formatter = DateFormat(pattern);
  String formattedTime = formatter.format(now);
  return "photo_$formattedTime";
}

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
                FileDropWidget(list: _selectedFileList, onClearAll: onClearAll),

                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        // Take a photo and save it to the device
                        String photoName = generatePhotoName(pattern1);

                        scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(content: Text("Photo saved as $photoName")),
                        );
                      },
                      child: Text("Take a photo name by pattern1"),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: () {
                        // Take a photo and save it to the device
                        String photoName = generatePhotoName(pattern2);

                        scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(content: Text("Photo saved as $photoName")),
                        );
                      },
                      child: Text("Take a photo name by pattern2"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
