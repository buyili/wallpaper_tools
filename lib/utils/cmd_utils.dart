import 'package:cmd_plus/cmd_plus.dart';

import 'cmd_plus_wrap.dart';

typedef ArgsSerializeCallback = String Function(List<String> args);

class CmdUtils {
  static final cmdPlus = CmdPlusWrap();

  static Future<CmdPlusResult> runCmd(
    String cmd,
    List<String> args, {
    ArgsSerializeCallback? argsSerialize,
  }) async {

    final result = await cmdPlus.run(
      cmd,
      args,

      /// Running in detached mode, so the process will not automatically print
      /// the output.
      // mode: const CmdPlusMode.detached(),
      throwOnError: false,
    );

    return result;
  }

}
