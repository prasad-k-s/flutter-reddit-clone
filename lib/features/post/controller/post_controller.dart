import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/storage_repository.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/repository/post_repository.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/posrt_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider = StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRePository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    ref: ref,
    storageRePository: storageRePository,
  );
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRePository _storageRePository;
  PostController({required StorageRePository storageRePository, required PostRepository postRepository, required Ref ref})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRePository = storageRePository,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community community,
    required String description,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final Post post = Post(
      id: postId,
      title: title,
      communityName: community.name,
      communityProfile: community.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );

    final res = await _postRepository.addPost(post);
    state = false;
    res.fold(
      (l) => showSnackbar(
        context: context,
        text: l.message,
        contentType: ContentType.failure,
        title: 'Oh snap!',
      ),
      (r) {
        showSnackbar(
          context: context,
          text: 'Posted Successfully',
          contentType: ContentType.success,
          title: 'Success',
        );
        Routemaster.of(context).pop();
      },
    );
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community community,
    required String link,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final Post post = Post(
      id: postId,
      title: title,
      communityName: community.name,
      communityProfile: community.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );

    final res = await _postRepository.addPost(post);
    state = false;
    res.fold(
      (l) => showSnackbar(
        context: context,
        text: l.message,
        contentType: ContentType.failure,
        title: 'Oh snap!',
      ),
      (r) {
        showSnackbar(
          context: context,
          text: 'Posted Successfully',
          contentType: ContentType.success,
          title: 'Success',
        );
        Routemaster.of(context).pop();
      },
    );
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community community,
    required File? file,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRePository.storeFile(
      path: 'posts/${community.name}',
      id: postId,
      file: file,
    );
    imageRes.fold(
        (l) => showSnackbar(
              context: context,
              text: l.message,
              contentType: ContentType.failure,
              title: 'Oh snap!',
            ), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: community.name,
        communityProfile: community.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'text',
        createdAt: DateTime.now(),
        awards: [],
        link: r,
      );

      final res = await _postRepository.addPost(post);
      state = false;
      res.fold(
        (l) => showSnackbar(
          context: context,
          text: l.message,
          contentType: ContentType.failure,
          title: 'Oh snap!',
        ),
        (r) {
          showSnackbar(
            context: context,
            text: 'Posted Successfully',
            contentType: ContentType.success,
            title: 'Success',
          );
          Routemaster.of(context).pop();
        },
      );
    });
  }
}