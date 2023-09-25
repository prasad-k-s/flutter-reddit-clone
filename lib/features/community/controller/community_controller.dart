// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/storage_repository.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/repository/community_repository.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/posrt_model.dart';
import 'package:routemaster/routemaster.dart';

final communityControllerProvider = StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRePository = ref.watch(storageRepositoryProvider);
  return CommunityController(communityRepository: communityRepository, ref: ref, storageRePository: storageRePository);
});

final userCommunityProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref.watch(communityControllerProvider.notifier).getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});
final getCommunityPostsProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityControllerProvider.notifier).getCommunityPost(name);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRePository _storageRePository;
  CommunityController(
      {required StorageRePository storageRePository, required CommunityRepository communityRepository, required Ref ref})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRePository = storageRePository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );
    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold(
      (l) {
        if (context.mounted) {
          showSnackbar(context: context, text: l.message, contentType: ContentType.failure, title: 'Oh snap!');
        }
      },
      (r) {
        if (context.mounted) {
          Routemaster.of(context).pop();
          showSnackbar(
              context: context,
              text: 'Community created successfully',
              contentType: ContentType.success,
              title: 'Congratulations!');
        }
      },
    );
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity({
    required Community community,
    required File? profileFile,
    required BuildContext context,
    required File? bannerFile,
  }) async {
    state = true;
    if (profileFile != null) {
      final result = await _storageRePository.storeFile(
        path: 'communities/profile',
        id: community.name,
        file: profileFile,
      );
      result.fold(
        (l) => showSnackbar(
          context: context,
          text: l.message,
          contentType: ContentType.failure,
          title: 'Oh snap!',
        ),
        (r) => community = community.copyWith(
          avatar: r,
        ),
      );
    }
    if (bannerFile != null) {
      final result = await _storageRePository.storeFile(
        path: 'communities/banner',
        id: community.name,
        file: bannerFile,
      );
      result.fold(
        (l) => showSnackbar(
          context: context,
          text: l.message,
          contentType: ContentType.failure,
          title: 'Oh snap!',
        ),
        (r) => community = community.copyWith(
          banner: r,
        ),
      );
    }
    final result = await _communityRepository.editCommunity(community);
    state = false;
    result.fold(
        (l) => showSnackbar(
              context: context,
              text: l.message,
              contentType: ContentType.failure,
              title: 'Oh snap!',
            ), (r) {
      if (context.mounted) {
        Routemaster.of(context).pop();
      }
    });
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider)!;
    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }

    res.fold((l) {
      showSnackbar(
        context: context,
        text: l.message,
        contentType: ContentType.failure,
        title: 'Oh sanp!',
      );
    }, (r) {
      if (community.members.contains(user.uid)) {
        showSnackbar(
          context: context,
          text: 'Community left successfully!',
          contentType: ContentType.success,
          title: 'Success',
        );
      } else {
        showSnackbar(
          context: context,
          text: 'Community joined successfully!',
          contentType: ContentType.success,
          title: 'Success',
        );
      }
    });
  }

  void addMods(String communityName, List<String> uids, BuildContext context) async {
    state = true;
    final res = await _communityRepository.addMods(communityName, uids);
    state = false;

    res.fold(
        (l) => showSnackbar(
              contentType: ContentType.failure,
              context: context,
              text: l.message,
              title: 'Oh snap!',
            ), (r) {
      showSnackbar(
        contentType: ContentType.success,
        context: context,
        text: 'Modrators updated successfully',
        title: 'Success',
      );
      if (context.mounted) {
        Routemaster.of(context).pop();
      }
    });
  }

  Stream<List<Post>> getCommunityPost(String name) {
    return _communityRepository.getCommunityPost(name);
  }
}
