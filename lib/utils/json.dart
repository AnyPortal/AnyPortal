import 'dart:convert';

String prettyPrintJson(String jsonString) {
  var jsonObject = json.decode(jsonString);
  var prettyString = const JsonEncoder.withIndent('  ').convert(jsonObject);
  return prettyString;
}

String minifyJson(String jsonString) {
  var jsonObject = json.decode(jsonString);
  var minifiedString = json.encode(jsonObject);
  return minifiedString;
}
