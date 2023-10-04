// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/responsive/responsive.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:string_validator/string_validator.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  const AddPostTypeScreen({required this.type, super.key});
  final String type;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final desController = TextEditingController();
  final linkController = TextEditingController();

  File? bannerFile;
  Uint8List? bannerWebFile;
  List<Community> communities = [];
  Community? selectedCommunity;

  final myKey = GlobalKey<FormState>();

  @override
  void dispose() {
    titleController.dispose();
    linkController.dispose();
    desController.dispose();
    super.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      if (kIsWeb) {
        setState(() {
          bannerWebFile = res.files.first.bytes;
        });
      } else {
        setState(() {
          bannerFile = File(res.files.first.path!);
        });
      }
    }
  }

  void sharePost(String isType) {
    final isValid = myKey.currentState!.validate();
    if (isValid) {
      if (isType == 'image') {
        if (bannerFile == null && bannerWebFile == null) {
          showSnackbar(
            context: context,
            text: 'Please pick a banner image',
            contentType: ContentType.warning,
            title: 'Pick image',
          );
        } else if (communities.isEmpty) {
          showSnackbar(
            context: context,
            text: 'You need to join a community to post',
            contentType: ContentType.warning,
            title: 'Join community',
          );
        } else {
          ref.read(postControllerProvider.notifier).shareImagePost(
                context: context,
                title: titleController.text.trim(),
                community: selectedCommunity ?? communities[0],
                file: bannerFile,
                webFile: bannerWebFile,
              );
        }
      } else if (isType == 'text') {
        if (communities.isEmpty) {
          showSnackbar(
            context: context,
            text: 'You need to join a community to post',
            contentType: ContentType.warning,
            title: 'Join community',
          );
        } else {
          ref.read(postControllerProvider.notifier).shareTextPost(
                context: context,
                title: titleController.text.trim(),
                community: selectedCommunity ?? communities[0],
                description: desController.text.trim(),
              );
        }
      } else if (isType == 'link') {
        if (communities.isEmpty) {
          showSnackbar(
            context: context,
            text: 'You need to join a community to post',
            contentType: ContentType.warning,
            title: 'Join community',
          );
        } else {
          ref.read(postControllerProvider.notifier).shareLinkPost(
                context: context,
                title: titleController.text.trim(),
                community: selectedCommunity ?? communities[0],
                link: linkController.text.trim(),
              );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final isLoading = ref.watch(postControllerProvider);

    if (isLoading) {
      return const Loader();
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Post ${widget.type}'),
        actions: [
          TextButton(
            onPressed: () => sharePost(widget.type),
            child: const Text('Share'),
          ),
        ],
      ),
      body: SafeArea(
        child: Responsive(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: myKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the title';
                      }
                      return null;
                    },
                    textInputAction: isTypeImage ? TextInputAction.done : TextInputAction.next,
                    controller: titleController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLength: 30,
                    decoration: InputDecoration(
                      errorStyle: const TextStyle(
                        fontSize: 16,
                      ),
                      filled: true,
                      hintText: 'Enter Title here',
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
                  const SizedBox(
                    height: 30,
                  ),
                  if (isTypeImage)
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
                          child: bannerWebFile != null
                              ? Image.memory(
                                  bannerWebFile!,
                                  fit: BoxFit.cover,
                                )
                              : bannerFile != null
                                  ? Image.file(
                                      bannerFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 40,
                                      ),
                                    ),
                        ),
                      ),
                    ),
                  if (isTypeText)
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the description';
                        }
                        return null;
                      },
                      controller: desController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(
                          fontSize: 16,
                        ),
                        filled: true,
                        hintText: 'Enter Description here',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                      ),
                      maxLines: 5,
                    ),
                  if (isTypeLink)
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the link';
                        }
                        if (!isURL(value)) {
                          return 'Please enter a valid link';
                        }
                        return null;
                      },
                      controller: linkController,
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(
                          fontSize: 16,
                        ),
                        filled: true,
                        hintText: 'Enter link here',
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
                  const SizedBox(
                    height: 20,
                  ),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Select Communtiy'),
                  ),
                  ref.watch(userCommunityProvider).when(
                    data: (data) {
                      communities = data;
                      if (data.isEmpty) {
                        return const Text('You haven\'t joined any community.');
                      }
                      return DropdownButton(
                        value: selectedCommunity ?? data[0],
                        items: data
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCommunity = value;
                          });
                        },
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
            ),
          ),
        ),
      ),
    );
  }
}
