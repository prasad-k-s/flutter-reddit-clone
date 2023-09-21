import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

void showSnackbar(
    {required BuildContext context, required String text, required ContentType contentType, required String title}) {
  final snackBar = SnackBar(
    elevation: 0,
    width: double.infinity,
    dismissDirection: DismissDirection.horizontal,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: title,
      message: text,
      contentType: contentType,
    ),
  );
  if (context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
