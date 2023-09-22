import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  const AddModsScreen({required this.name, super.key});
  final String name;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};

  void addUids(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUids(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref.read(communityControllerProvider.notifier).addMods(
          widget.name,
          uids.toList(),
          context,
        );
  }

  int count = 0;
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);

    if (isLoading) {
      return const Loader();
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add Moderators',
        ),
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(
              Icons.done,
            ),
          ),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (community) {
          return ListView.builder(
            itemCount: community.members.length,
            itemBuilder: (context, index) {
              final member = community.members[index];

              return ref.watch(getUserDataProvider(member)).when(
                data: (user) {
                  if (community.mods.contains(member) && count == 0) {
                    uids.add(member);
                  }
                  count++;
                  return CheckboxListTile.adaptive(
                    value: uids.contains(user.uid),
                    onChanged: (value) {
                      if (value!) {
                        addUids(user.uid);
                      } else {
                        removeUids(user.uid);
                      }
                    },
                    title: Text(user.name),
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
              );
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
    );
  }
}
