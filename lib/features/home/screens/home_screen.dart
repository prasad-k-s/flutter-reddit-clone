import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/home/delegates/search_community_delegate.dart';
import 'package:reddit_clone/features/home/drawers/community_list_drawer.dart';
import 'package:reddit_clone/features/home/drawers/profile_drawer.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void disPlayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void disPlayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onTap(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final isLoading = ref.watch(authControllerProvider);
    if (isLoading) {
      return const Loader();
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home'),
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
          if (kIsWeb)
            IconButton(
              onPressed: () {
                Routemaster.of(context).push('/add-post');
              },
              icon: const Icon(
                Icons.add,
              ),
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
      ),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      drawer: const CommunityListDrawer(),
      bottomNavigationBar: isGuest || kIsWeb
          ? null
          : CupertinoTabBar(
              activeColor: currentTheme.iconTheme.color,
              // ignore: deprecated_member_use
              backgroundColor: currentTheme.backgroundColor,
              currentIndex: _page,
              onTap: onTap,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: '',
                )
              ],
            ),
      body: Constants.tabWidgets[_page],
    );
  }
}
