import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'main_page/file_drop.dart';
import 'main_page/resize_opt.dart';


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
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void copyToClipboard(String text, {
    String? snackBarText,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    // 可选：显示一个提示给用户，告诉他们文本已经被复制
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(snackBarText ?? "Text copied to clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(flex: 8, child: FileDropWidget()),
                  Flexible(flex: 5, child: ResizeOpt())
                ],
              ),

              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () {
                      // Take a photo and save it to the device
                      String photoName = generatePhotoName(pattern1);

                      copyToClipboard(photoName, snackBarText: "Photo saved as $photoName");
                    },
                    child: Text("Take a photo name by pattern1"),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {
                      // Take a photo and save it to the device
                      String photoName = generatePhotoName(pattern2);

                      copyToClipboard(photoName, snackBarText: "Photo saved as $photoName");
                    },
                    child: Text("Take a photo name by pattern2"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
