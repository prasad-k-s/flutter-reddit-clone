import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/enums/enumns.dart';
import 'package:reddit_clone/core/storage_repository.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/user_profile/repository/user_profile_repository.dart';
import 'package:reddit_clone/models/posrt_model.dart';
import 'package:reddit_clone/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider = StateNotifierProvider<UserProfileController, bool>(
  (ref) {
    final userProfileRepository = ref.watch(userProfileRepositoryProvider);
    final storageRePository = ref.watch(storageRepositoryProvider);
    return UserProfileController(
      userProfileRepository: userProfileRepository,
      ref: ref,
      storageRePository: storageRePository,
    );
  },
);

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.read(userProfileControllerProvider.notifier).getUserPost(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRePository _storageRePository;
  UserProfileController(
      {required StorageRePository storageRePository, required UserProfileRepository userProfileRepository, required Ref ref})
      : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRePository = storageRePository,
        super(false);

  void editCommunity({
    required File? profileFile,
    required BuildContext context,
    required File? bannerFile,
    required String name,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null) {
      final result = await _storageRePository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
      );
      result.fold(
        (l) => showSnackbar(
          context: context,
          text: l.message,
          contentType: ContentType.failure,
          title: 'Oh snap!',
        ),
        (r) => user = user.copyWith(
          profilePic: r,
        ),
      );
    }
    if (bannerFile != null) {
      final result = await _storageRePository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
      );
      result.fold(
        (l) => showSnackbar(
          context: context,
          text: l.message,
          contentType: ContentType.failure,
          title: 'Oh snap!',
        ),
        (r) => user = user.copyWith(
          banner: r,
        ),
      );
    }
    user = user.copyWith(name: name);
    final result = await _userProfileRepository.editProfile(user);
    state = false;
    result.fold(
        (l) => showSnackbar(
              context: context,
              text: l.message,
              contentType: ContentType.failure,
              title: 'Oh snap!',
            ), (r) {
      if (context.mounted) {
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).pop();
      }
    });
  }

  Stream<List<Post>> getUserPost(String uid) {
    return _userProfileRepository.getUserPost(uid);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);

    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold(
      (l) => null,
      (r) => _ref.read(userProvider.notifier).update(
            (state) => user,
          ),
    );
  }
}
