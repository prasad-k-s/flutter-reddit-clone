import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    if (isGuest) {
      return ref.watch(guestpostProvider).when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'There are no post to display.',
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(post: post);
            },
          );
        },
        error: (error, stackTrace) {
          return Scaffold(
            body: ErrorText(
              error: error.toString(),
            ),
          );
        },
        loading: () {
          return const Loader();
        },
      );
    } else {
      return ref.watch(userCommunityProvider).when(
        data: (communities) {
          if (communities.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t joined any community yet.\n Join a community to see posts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            );
          }
          return ref.watch(userPostProvider(communities)).when(
            data: (posts) {
              if (posts.isEmpty) {
                return const Center(
                  child: Text(
                    'There are no post to display.',
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostCard(post: post);
                },
              );
            },
            error: (error, stackTrace) {
              return Scaffold(
                body: ErrorText(
                  error: error.toString(),
                ),
              );
            },
            loading: () {
              return const Loader();
            },
          );
        },
        error: (error, stackTrace) {
          return Scaffold(
            body: ErrorText(
              error: error.toString(),
            ),
          );
        },
        loading: () {
          return const Loader();
        },
      );
    }
  }
}
