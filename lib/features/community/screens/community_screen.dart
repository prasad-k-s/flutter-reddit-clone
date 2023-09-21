import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({required this.name, super.key});

  final String name;

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(userProvider)?.uid;
    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
        data: (community) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          color: Colors.grey,
                          child: Image.network(
                            community.banner,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Align(
                          alignment: Alignment.topLeft,
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(
                              community.avatar,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'r/${community.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                              ),
                            ),
                            community.mods.contains(uid)
                                ? OutlinedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 25,
                                        ),
                                        backgroundColor: Colors.grey.withOpacity(0.15),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                    onPressed: () => navigateToModTools(context),
                                    child: const Text('Mod Tools'),
                                  )
                                : OutlinedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 25,
                                        ),
                                        backgroundColor: Colors.grey.withOpacity(0.15),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                    onPressed: () {},
                                    child: Text(community.members.contains(uid) ? 'Joined' : 'Join'),
                                  ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                              community.members.isEmpty ? 'No member joined yet' : '${community.members.length} members'),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Text(name),
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
