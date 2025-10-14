import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

Exception errorHandler(Response response, String context) {
  final res = jsonDecode(response.body);
  final detail = res['detail'] ?? 'Unknown error';
  debugPrint('$context error ${response.statusCode}: ${detail.toString()}');
  return Exception(detail.toString());
}

Exception streamErrorHandler(
  StreamedResponse response,
  String detail,
  String context,
) {
  debugPrint('$context error ${response.statusCode}: ${detail.toString()}');
  return Exception(detail.toString());
}

void showErrorSnackBar(BuildContext context, String message) {
  if (context.mounted) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else {
    debugPrint('Context is not mounted. Cannot show SnackBar.');
  }
}

void showSuccessSnackBar(BuildContext context, String message) {
  if (context.mounted) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else {
    debugPrint('Context is not mounted. Cannot show SnackBar.');
  }
}
