// ignore_for_file: deprecated_member_use

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  const EditCommunityScreen({required this.name, super.key});
  final String name;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.darkModeAppTheme.backgroundColor,
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Edit community"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Save'),
          )
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (community) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        DottedBorder(
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
                            child: community.banner.isEmpty || community.banner == Constants.bannerDefault
                                ? const Center(
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                    ),
                                  )
                                : Image.network(community.banner),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          bottom: 20,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 32,
                            backgroundImage: NetworkImage(
                              community.avatar,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
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
    );
  }
}
