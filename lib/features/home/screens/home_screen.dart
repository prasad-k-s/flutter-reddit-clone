import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/home/drawers/community_list_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  void disPlayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(user.profilePic),
            ),
          ),
        ],
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () => disPlayDrawer(context),
              icon: const Icon(
                Icons.menu,
              ),
            );
          },
        ),
        title: const Text('Home'),
      ),
      drawer: const CommunityListDrawer(),
      body: SafeArea(
        child: Center(
          child: Text(user.profilePic),
        ),
      ),
    );
  }
}
