import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/file_provider.dart';
import '../../utils/cmd_utils.dart';
import '../../utils/file_utils.dart';

class ResizeOptions {
  late String label;
  String value;

  ResizeOptions({required this.label, required this.value});

  ResizeOptions.fromValue(this.value){
    label = value;
  }


}

class SizeOptions {
  String label;
  List<ResizeOptions> resizeOption;

  SizeOptions({required this.label, required this.resizeOption});
}

List<ResizeOptions> generateResizeOptions(String width, String height) {
  return [
    ResizeOptions.fromValue('${width}x$height'),
    ResizeOptions.fromValue('${width}x$height^'),
    ResizeOptions.fromValue('${width}x$height!'),
    ResizeOptions.fromValue('${width}x$height>'),
    ResizeOptions.fromValue('${width}x$height<'),
    ResizeOptions.fromValue('${width}x'),
    ResizeOptions.fromValue('x$height'),
    ResizeOptions.fromValue('${height}x'),
    ResizeOptions.fromValue('x$width'),
  ];
}

List<ResizeOptions> resize4K16x9Options = generateResizeOptions('3840', '2160');

List<ResizeOptions> resize4k16x10Options = generateResizeOptions('3840', '2400');

List<ResizeOptions> resize4kDualOptions = generateResizeOptions('5120', '2048');

List<ResizeOptions> resize1kOptions = generateResizeOptions('1920', '1080');

List<SizeOptions> sizeOptions = [
  SizeOptions(label: '16:9 4K 3840*2160', resizeOption: resize4K16x9Options),
  SizeOptions(label: '16:10 4K 3840*2400', resizeOption: resize4k16x10Options),
  SizeOptions(label: 'Dual 4K 5120*2048', resizeOption: resize4kDualOptions),
  SizeOptions(label: '16x9 1K 1920*1080', resizeOption: resize1kOptions),
];

class ResizeOpt extends ConsumerStatefulWidget {
  const ResizeOpt({super.key});

  @override
  ConsumerState<ResizeOpt> createState() => _ResizeOptState();
}

class _ResizeOptState extends ConsumerState<ResizeOpt> {
  void _magickResize(ResizeOptions resizeData) {
    for (var file in ref.read(selectedFilesProvider)) {
      var newFilePath = FileUtils.addSuffixToFileName(
        file.path,
        "_${resizeData.value}",
      );
      var args = [file.path, "-resize", resizeData.value, newFilePath];
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sizeOptions.map(
          (sizeData) => ResizeOptItem(
            label: sizeData.label,
            resizeOptions: sizeData.resizeOption,
            onResize: _magickResize,
          ),
        ),
      ],
    );
  }
}

class ResizeOptItem extends StatelessWidget {
  final String label;
  final List<ResizeOptions> resizeOptions;
  final Function(ResizeOptions) onResize;

  const ResizeOptItem({
    super.key,
    required this.label,
    required this.resizeOptions,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:'),
          Wrap(
            children:
                resizeOptions
                    .map(
                      (resizeData) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClickableText(
                            text: '${resizeData.label},',
                            onTap: (text) {
                              onResize(resizeData);
                            },
                          ),
                          const SizedBox(width: 8.0),
                        ],
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class ClickableText extends StatelessWidget {
  const ClickableText({super.key, required this.text, this.onTap});

  final String text;
  final Function(String)? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(text);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(text, style: const TextStyle(fontSize: 18,color: Colors.blue)),
      ),
    );
  }
}
