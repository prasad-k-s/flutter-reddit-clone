import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/posrt_model.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({required this.postId, super.key});
  final String postId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();
  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
          context: context,
          text: commentController.text.trim(),
          post: post,
        );
    setState(() {
      commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Comments'),
      ),
      body: ref
          .watch(
        getPostByIdProvider(widget.postId),
      )
          .when(
        data: (post) {
          return Column(
            children: [
              PostCard(post: post),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'what are your thoughts',
                  filled: true,
                  border: InputBorder.none,
                ),
              ),
            ],
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
      ),
    );
  }
}
