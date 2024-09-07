import 'dart:async';
import 'dart:io';
import 'dart:convert';


class CLIProcessWrapper {
  Process? _process;
  bool on = false;
  final List<String> output = [];
  final int maxLines;
  final StreamController<List<String>> outputController = StreamController<List<String>>.broadcast();

  CLIProcessWrapper({this.maxLines = 1000});

  Stream<List<String>> get outputStream => outputController.stream;

  Future<void> startProcess(String executable, List<String> arguments, {String? workingDirectory, Map<String, String>? environment}) async {
    if (_process != null) {
      stopProcess(); // stop any existing process
    }
    
    output.clear(); // Reset output buffer
    outputController.add(output); // Reset the stream
    if (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS){
      await Process.run("chmod", ["a+x", executable]);
    }

    _process = await Process.start(executable, arguments, workingDirectory: workingDirectory, environment: environment);
    on = true;

    _process?.stdout.transform(utf8.decoder).listen((data) {
      if (data != "") _addOutput(data);
    });

    _process?.stderr.transform(utf8.decoder).listen((data) {
      if (data != "") _addOutput(data);
    });
  }

  void _addOutput(String data) {
    final lines = data.split("\n");
    for (var line in lines){
      // if (line.isNotEmpty) output.add(line.substring(0, line.length - 1));
      if (line.isNotEmpty) output.add(line);
    }
    // output.addAll(lines);
    while (output.length > maxLines) {
      output.removeAt(0); // Keep the buffer to maxLines
    }
    outputController.add(List.from(output)); // Send a copy of the list to avoid concurrency issues
  }

  void stopProcess() {
    _process?.kill();
    _process = null;
    on = false;
  }

  void dispose() {
    // outputController.close();
  }
}