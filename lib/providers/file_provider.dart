import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedFilesProvider = StateProvider<List<XFile>>((ref) => []);