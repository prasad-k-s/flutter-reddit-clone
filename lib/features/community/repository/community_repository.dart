import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_provider.dart';
import 'package:reddit_clone/core/type_def.dart';
import 'package:reddit_clone/models/community_model.dart';

final communityRepositoryProvider = Provider(
  (ref) {
    return CommunityRepository(
      firestore: ref.watch(firestoreProvider),
    );
  },
);

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();

      if (communityDoc.exists) {
        throw 'Community with the same name already exists!';
      } else {
        return right(
          _communities.doc(community.name).set(
                community.toMap(),
              ),
        );
      }
    } on FirebaseException catch (e) {
      return left(
        Failure(e.message ?? 'Something went wrong'),
      );
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities.where('members', arrayContains: uid).snapshots().map(
      (event) {
        List<Community> communities = [];

        for (var doc in event.docs) {
          communities.add(
            Community.fromMap(
              doc.data() as Map<String, dynamic>,
            ),
          );
        }
        return communities;
      },
    );
  }

  CollectionReference get _communities => _firestore.collection(
        FirebaseConstants.communitiesCollection,
      );
}
