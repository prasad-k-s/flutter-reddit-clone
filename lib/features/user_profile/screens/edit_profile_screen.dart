// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({required this.uid, super.key});
  final String uid;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? profileFile;
  late TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    nameController = TextEditingController(
      text: ref.read(userProvider)!.name,
    );
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

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

  void save() {
    final isValid = myKey.currentState!.validate();
    if (isValid) {
      ref.read(userProfileControllerProvider.notifier).editCommunity(
            profileFile: profileFile,
            context: context,
            bannerFile: bannerFile,
            name: nameController.text.trim(),
          );
    }
  }

  final myKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(userProfileControllerProvider);
    if (isLoading) {
      return const Loader();
    }
    return ref.watch(getUserDataProvider(widget.uid)).when(
      data: (community) {
        return Scaffold(
          backgroundColor: currentTheme.backgroundColor,
          appBar: AppBar(
            centerTitle: false,
            title: const Text("Edit Profile"),
            actions: [
              TextButton(
                onPressed: () => save(),
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
                            color: currentTheme.textTheme.bodyText2!.color!,
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
                                      community.profilePic,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: myKey,
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.length < 4) {
                          return 'Name must contain atleast 4 characters';
                        }
                        return null;
                      },
                      controller: nameController,
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(
                          fontSize: 16,
                        ),
                        filled: true,
                        hintText: 'Name',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                      ),
                    ),
                  ),
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
