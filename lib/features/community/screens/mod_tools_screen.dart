import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ModToolScreen extends ConsumerWidget {
  const ModToolScreen({required this.name, super.key});
  final String name;
  void navigateToEditCommunity(BuildContext context) {
    Routemaster.of(context).push('/edit-community/$name');
  }

  void navigateToAddMods(BuildContext context) {
    Routemaster.of(context).push('/add-mods/$name');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mod Tools'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.add_moderator,
            ),
            onTap: () => navigateToAddMods(context),
            title: const Text('Add Moderators'),
          ),
          ListTile(
            leading: const Icon(
              Icons.edit,
            ),
            onTap: () => navigateToEditCommunity(context),
            title: const Text('Edit Community'),
          ),
        ],
      ),
    );
  }
}
