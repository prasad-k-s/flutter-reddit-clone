import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/features/post/widget/comment_card.dart';
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
    final isValid = myKey.currentState!.validate();
    if (isValid) {
      ref.read(postControllerProvider.notifier).addComment(
            context: context,
            text: commentController.text.trim(),
            post: post,
          );
      commentController.clear();
    }
  }

  final myKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
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
          return SingleChildScrollView(
            child: Column(
              children: [
                PostCard(post: post),
                if (!isGuest)
                  Form(
                    key: myKey,
                    child: TextFormField(
                      controller: commentController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter something';
                        }
                        return null;
                      },
                      autofocus: true,
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(
                          fontSize: 16,
                        ),
                        suffix: GestureDetector(
                          onTap: () => addComment(post),
                          child: const Text(
                            'Post',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        hintText: 'what are your thoughts?',
                        filled: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ref.watch(getPostCommentsProvider(widget.postId)).when(
                  data: (data) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final comment = data[index];
                          return CommentCard(
                            comment: comment,
                          );
                        },
                      ),
                    );
                  },
                  error: (error, stackTrace) {
                    return ErrorText(
                      error: error.toString(),
                    );
                  },
                  loading: () {
                    return Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.orange.shade900,
                      ),
                    );
                  },
                ),
              ],
            ),
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
