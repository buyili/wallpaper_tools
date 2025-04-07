import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static String addSuffixToFileName(String fileName, String suffix) {
    return fileName.replaceAll(RegExp(r'\.[^.]+$'), suffix) +
        fileName.substring(fileName.lastIndexOf('.'));
  }

  /// Changes the suffix of a file name.
  ///
  /// Example:
  /// ```
  /// changeSuffix('file.txt', 'pdf') => 'file.pdf'
  /// ```
  static changeSuffix(String fileName, String newSuffix) {
    return fileName.replaceAll(RegExp(r'\.[^.]+$'), '.$newSuffix');
  }

  static void checkFileAndConfirm(BuildContext context, String filePath, {
    Function()? onConfirmed,
    Function()? onCanceled,
  }) async {
    final File file = File(filePath);

    if (await file.exists()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('File Exists'),
            content: Text('File already exists. Do you want to overwrite it？'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭对话框
                  if (onCanceled!= null) {
                    onCanceled();
                  }
                },
              ),
              TextButton(
                child: Text('Overwrite'),
                onPressed: () async {
                  // 在这里执行覆盖文件的操作
                  Navigator.of(context).pop(); // 关闭对话框
                  if (onConfirmed!= null) {
                    onConfirmed();
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      // 如果文件不存在，可以在这里执行创建文件的操作
      if (onConfirmed!= null) {
        onConfirmed();
      }
    }
  }
}
