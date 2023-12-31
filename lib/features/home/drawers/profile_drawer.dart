import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logOut(WidgetRef ref, BuildContext context) async {
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) {
      Routemaster.of(context).pop();
    }
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  user.profilePic,
                ),
                radius: 70,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'u/${user.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              title: const Text('My profile'),
              leading: const Icon(Icons.person),
              onTap: () => navigateToUserProfile(context, user.uid),
            ),
            ListTile(
              title: const Text('Logout'),
              leading: Icon(
                Icons.logout,
                color: Pallete.redColor,
              ),
              onTap: () => logOut(ref, context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                children: [
                  ref.watch(themeNotifierProvider.notifier).mode == ThemeMode.dark
                      ? Icon(
                          Icons.dark_mode,
                          color: Pallete.blueColor,
                        )
                      : Icon(
                          Icons.light_mode,
                          color: Pallete.blueColor,
                        ),
                  const SizedBox(
                    width: 22,
                  ),
                  Switch.adaptive(
                    value: ref.watch(themeNotifierProvider.notifier).mode == ThemeMode.dark,
                    onChanged: (value) => toggleTheme(ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
