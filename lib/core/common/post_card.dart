import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/posrt_model.dart';
import 'package:reddit_clone/theme/pallete.dart';

class PostCard extends ConsumerWidget {
  const PostCard({required this.post, super.key});
  final Post post;

  void deletePost(WidgetRef ref, BuildContext context) {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final user = ref.watch(userProvider)!;

    return SafeArea(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: currentTheme.drawerTheme.backgroundColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ).copyWith(right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage: NetworkImage(
                                        post.communityProfile,
                                      ),
                                      radius: 16,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'r/${post.communityName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'u/${post.username}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (post.uid == user.uid)
                                  IconButton(
                                    onPressed: () => deletePost(ref, context),
                                    icon: Icon(
                                      Icons.delete,
                                      color: Pallete.redColor,
                                    ),
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isTypeImage)
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.35,
                                width: double.infinity,
                                child: Image.network(
                                  post.link!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (isTypeLink)
                              Padding(
                                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                                child: AnyLinkPreview(
                                  placeholderWidget: const SizedBox(
                                    height: 160,
                                    width: double.infinity,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.deepOrangeAccent,
                                      ),
                                    ),
                                  ),
                                  errorWidget: SizedBox(
                                    height: 160,
                                    width: double.infinity,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error,
                                            color: Pallete.redColor,
                                            size: 40,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Error loading link',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Pallete.redColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  displayDirection: UIDirection.uiDirectionHorizontal,
                                  link: post.link!,
                                ),
                              ),
                            if (isTypeText)
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Constants.up,
                                        size: 30,
                                        color: post.upvotes.contains(user.uid) ? Pallete.redColor : null,
                                      ),
                                    ),
                                    Text(
                                      post.upvotes.length - post.downvotes.length == 0
                                          ? 'Vote'
                                          : '${post.upvotes.length - post.downvotes.length}',
                                      style: const TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Constants.down,
                                        size: 30,
                                        color: post.upvotes.contains(user.uid) ? Pallete.blueColor : null,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.comment,
                                        size: 30,
                                      ),
                                    ),
                                    Text(
                                      post.commentCount == 0 ? 'Comment' : '${post.commentCount}',
                                      style: const TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
