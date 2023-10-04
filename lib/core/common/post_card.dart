import 'package:any_link_preview/any_link_preview.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/posrt_model.dart';
import 'package:reddit_clone/responsive/responsive.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  const PostCard({required this.post, super.key});
  final Post post;

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(
          post,
        );
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref.read(postControllerProvider.notifier).awardPost(
          post: post,
          award: award,
          context: context,
        );
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(
          post,
        );
  }

  void navigateToProfile(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComments(BuildContext context, String postId) {
    Routemaster.of(context).push('/comments/$postId');
  }

  void adminButton(BuildContext context) {
    showSnackbar(
      context: context,
      text: 'Admin settings is yet to be implemented',
      contentType: ContentType.warning,
      title: 'Admin settings',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return SafeArea(
      child: Responsive(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: currentTheme.drawerTheme.backgroundColor,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kIsWeb)
                    Column(
                      children: [
                        IconButton(
                          onPressed: isGuest ? null : () => upvotePost(ref),
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
                          onPressed: isGuest ? null : () => downvotePost(ref),
                          icon: Icon(
                            Constants.down,
                            size: 30,
                            color: post.downvotes.contains(user.uid) ? Pallete.blueColor : null,
                          ),
                        ),
                      ],
                    ),
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
                                      GestureDetector(
                                        onTap: () => navigateToCommunity(context),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          backgroundImage: NetworkImage(
                                            post.communityProfile,
                                          ),
                                          radius: 16,
                                        ),
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
                                            GestureDetector(
                                              onTap: () => navigateToProfile(context),
                                              child: Text(
                                                'u/${post.username}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
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
                              if (post.awards.isNotEmpty) ...[
                                const SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  height: 25,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: post.awards.length,
                                    itemBuilder: (context, index) {
                                      return Image.asset(
                                        Constants.awards[post.awards[index]]!,
                                        height: 23,
                                      );
                                    },
                                  ),
                                ),
                              ],
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
                                Container(
                                  color: Colors.grey,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!kIsWeb)
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: isGuest ? null : () => upvotePost(ref),
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
                                          onPressed: isGuest ? null : () => downvotePost(ref),
                                          icon: Icon(
                                            Constants.down,
                                            size: 30,
                                            color: post.downvotes.contains(user.uid) ? Pallete.blueColor : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => navigateToComments(context, post.id),
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
                                  ref.watch(getCommunityByNameProvider(post.communityName)).when(
                                    data: (data) {
                                      if (data.mods.contains(user.uid)) {
                                        return IconButton(
                                          onPressed: () => adminButton(context),
                                          icon: const Icon(
                                            Icons.admin_panel_settings,
                                          ),
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    },
                                    error: (error, stackTrace) {
                                      return ErrorText(
                                        error: error.toString(),
                                      );
                                    },
                                    loading: () {
                                      return const CircularProgressIndicator.adaptive();
                                    },
                                  ),
                                  if (post.uid != user.uid)
                                    IconButton(
                                      onPressed: isGuest
                                          ? null
                                          : () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(20),
                                                      child: GridView.builder(
                                                        shrinkWrap: true,
                                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 4),
                                                        itemCount: user.awards.length,
                                                        itemBuilder: (context, index) {
                                                          final award = user.awards[index];
                                                          return GestureDetector(
                                                            onTap: () => awardPost(ref, award, context),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Image.asset(
                                                                Constants.awards[award]!,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                      icon: const Icon(
                                        Icons.card_giftcard_outlined,
                                      ),
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
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
