import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/sign_in_button.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
    Scaffold.of(context).closeDrawer();
  }

  void navigateToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const DrawerHeader(
              child: Icon(
                Icons.reddit,
                size: 100,
                color: Colors.deepOrangeAccent,
              ),
            ),
            isGuest
                ? const SignInButton()
                : ListTile(
                    title: const Text('Create a community'),
                    leading: const Icon(Icons.add),
                    onTap: () => navigateToCreateCommunity(context),
                  ),
            if (!isGuest)
              ref.watch(userCommunityProvider).when(
                data: (communities) {
                  if (communities.isEmpty) {
                    return const Center(
                      child: Text(
                        'You haven\'t joined any community',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: communities.length,
                      itemBuilder: (context, index) {
                        final community = communities[index];
                        return ListTile(
                          onTap: () {
                            navigateToCommunity(context, community);
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(community.avatar),
                          ),
                          title: Text(
                            'r/${community.name}',
                          ),
                        );
                      },
                    ),
                  );
                },
                error: (error, stackTrace) {
                  return Center(
                    child: ErrorText(
                      error: error.toString(),
                    ),
                  );
                },
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )
          ],
        ),
      ),
    );
  }
}
