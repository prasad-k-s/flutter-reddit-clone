import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class AddPostsScreen extends ConsumerWidget {
  const AddPostsScreen({super.key});

  void naviagteToType(BuildContext context, String type) {
    Routemaster.of(context).push('/add-post/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardHeightWidth = 120;
    double iconSize = 60;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MyCardWidget(
          cardHeightWidth: cardHeightWidth,
          currentTheme: currentTheme,
          iconSize: iconSize,
          onTap: () => naviagteToType(context, 'image'),
          iconData: Icons.image_outlined,
        ),
        MyCardWidget(
          cardHeightWidth: cardHeightWidth,
          currentTheme: currentTheme,
          iconSize: iconSize,
          onTap: () => naviagteToType(context, 'text'),
          iconData: Icons.font_download_outlined,
        ),
        MyCardWidget(
          cardHeightWidth: cardHeightWidth,
          currentTheme: currentTheme,
          iconSize: iconSize,
          onTap: () => naviagteToType(context, 'link'),
          iconData: Icons.link_outlined,
        ),
      ],
    );
  }
}

class MyCardWidget extends StatelessWidget {
  const MyCardWidget({
    super.key,
    required this.cardHeightWidth,
    required this.currentTheme,
    required this.iconSize,
    required this.onTap,
    required this.iconData,
  });

  final double cardHeightWidth;
  final ThemeData currentTheme;
  final double iconSize;
  final VoidCallback onTap;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: cardHeightWidth,
        width: cardHeightWidth,
        child: Card(
          // ignore: deprecated_member_use
          color: currentTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 16,
          child: Center(
            child: Center(
              child: Icon(
                iconData,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
