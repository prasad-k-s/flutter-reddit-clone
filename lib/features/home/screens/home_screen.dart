import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/home/delegates/search_community_delegate.dart';
import 'package:reddit_clone/features/home/drawers/community_list_drawer.dart';
import 'package:reddit_clone/features/home/drawers/profile_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  void disPlayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void disPlayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isLoading = ref.watch(authControllerProvider);
    if (isLoading) {
      return const Loader();
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchCommunityDelegate(
                  ref: ref,
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => disPlayEndDrawer(context),
              icon: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(user.profilePic),
              ),
            );
          }),
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
      endDrawer: const ProfileDrawer(),
      drawer: const CommunityListDrawer(),
      body: SafeArea(
        child: Center(
          child: Text(user.profilePic),
        ),
      ),
    );
  }
}
