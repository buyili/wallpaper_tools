class FileUtils {
  static String addSuffixToFileName(String fileName, String suffix) {
    return fileName.replaceAll(RegExp(r'\.[^.]+$'), suffix) +
        fileName.substring(fileName.lastIndexOf('.'));
  }
}
