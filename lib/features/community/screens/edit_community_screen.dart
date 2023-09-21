// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  const EditCommunityScreen({required this.name, super.key});
  final String name;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  void save(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
          community: community,
          profileFile: profileFile,
          context: context,
          bannerFile: bannerFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);

    if (isLoading) {
      return const Loader();
    } else {
      return ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (community) {
          return Scaffold(
            backgroundColor: Pallete.darkModeAppTheme.backgroundColor,
            appBar: AppBar(
              centerTitle: false,
              title: const Text("Edit community"),
              actions: [
                TextButton(
                  onPressed: () => save(community),
                  child: const Text('Save'),
                )
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: selectBannerImage,
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              dashPattern: const [10, 4],
                              strokeCap: StrokeCap.round,
                              color: Pallete.darkModeAppTheme.textTheme.bodyText2!.color!,
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: bannerFile != null
                                    ? Image.file(
                                        bannerFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : community.banner.isEmpty || community.banner == Constants.bannerDefault
                                        ? const Center(
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              size: 40,
                                            ),
                                          )
                                        : Image.network(
                                            community.banner,
                                            fit: BoxFit.cover,
                                          ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            bottom: 20,
                            child: GestureDetector(
                              onTap: selectProfileImage,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 32,
                                backgroundImage: profileFile != null
                                    ? Image.file(profileFile!).image
                                    : NetworkImage(
                                        community.avatar,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        error: (error, stackTrace) {
          return Scaffold(
            body: Center(
              child: ErrorText(
                error: error.toString(),
              ),
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
