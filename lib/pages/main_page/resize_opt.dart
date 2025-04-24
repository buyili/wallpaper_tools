import 'package:flutter/material.dart';

class ResizeOptions {
  String label;
  String value;

  ResizeOptions({required this.label, required this.value});
}

class SizeOptions {
  String label;
  List<ResizeOptions> resizeOption;

  SizeOptions({required this.label, required this.resizeOption});
}

List<ResizeOptions> resize4K16x9Options = [
  ResizeOptions(label: '3840x', value: '3840x'),
  ResizeOptions(label: 'x2160', value: 'x2160'),
];

List<ResizeOptions> resize4k16x10Options = [
  ResizeOptions(label: '3840x', value: '3840x'),
  ResizeOptions(label: 'x2400', value: 'x2400'),
];

List<ResizeOptions> resize4kDualOptions = [
  ResizeOptions(label: '5120x', value: '5120x'),
  ResizeOptions(label: 'x2048', value: 'x2048'),
];

List<SizeOptions> sizeOptions = [
  SizeOptions(
    label: '16:9 4K 3840*2160',
    resizeOption: resize4K16x9Options,
  ),
  SizeOptions(
    label: '16:10 4K 3840*2400',
    resizeOption: resize4k16x10Options,
  ),
  SizeOptions(
    label: 'Dual 4K 5120*2048',
    resizeOption: resize4kDualOptions,
  ),
];

class ResizeOpt extends StatelessWidget {
  const ResizeOpt({super.key});


  void _magickResizeTo1K(String size) {
    // for (var file in widget.list) {
    //   var newFilePath = FileUtils.addSuffixToFileName(file.path, "_1k");
    //   var args = [file.path, "-resize", size, newFilePath];
    //   if (kDebugMode) {
    //     print("magick ${args.join(" ")}");
    //   }
    //   FileUtils.checkFileAndConfirm(
    //     context,
    //     newFilePath,
    //     onConfirmed: () {
    //       CmdUtils.runCmd("magick", args);
    //     },
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ...sizeOptions.map((sizeData) => ResizeOptItem(label: sizeData.label, resizeOptions: sizeData.resizeOption)),
      ],
    );
  }
}

class ResizeOptItem extends StatelessWidget {
  final String label;
  final List<ResizeOptions> resizeOptions;

  const ResizeOptItem({
    super.key,
    required this.label,
    required this.resizeOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text('$label:'),
          const SizedBox(width: 10),
          SegmentedButton<ResizeOptions>(
            segments:
                resizeOptions
                    .map(
                      (resizeData) => ButtonSegment<ResizeOptions>(
                        value: resizeData,
                        label: Text(resizeData.label),
                      ),
                    )
                    .toList(),
            selected: <ResizeOptions>{resizeOptions[0]},
            onSelectionChanged: (Set<ResizeOptions> newSelection) {},
          ),
        ],
      ),
    );
  }
}
