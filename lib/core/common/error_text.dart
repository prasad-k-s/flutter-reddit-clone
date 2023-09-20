import 'package:flutter/material.dart';
import 'package:reddit_clone/theme/pallete.dart';

class ErrorText extends StatelessWidget {
  const ErrorText({super.key, required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        error,
        style: TextStyle(
          fontSize: 16,
          color: Pallete.redColor,
        ),
      ),
    );
  }
}
