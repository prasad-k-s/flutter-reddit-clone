import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_provider.dart';
import 'package:reddit_clone/core/type_def.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/posrt_model.dart';

final postRepositoryProvider = Provider(
  (ref) {
    return PostRepository(
      firestore: ref.watch(firestoreProvider),
    );
  },
);

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _posts => _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(
        _posts.doc(post.id).set(
              post.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  Stream<List<Post>> fetchUserPost(List<Community> communities) {
    return _posts
        .where(
          'communityName',
          whereIn: communities.map((e) => e.name).toList(),
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(e.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(
        _posts.doc(post.id).delete(),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  void upvote(Post post, String userID) async {
    if (post.downvotes.contains(userID)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userID]),
      });
    }
    if (post.upvotes.contains(userID)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userID]),
      });
    } else {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userID]),
      });
    }
  }

  void downvote(Post post, String userID) async {
    if (post.upvotes.contains(userID)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userID]),
      });
    }
    if (post.downvotes.contains(userID)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userID]),
      });
    } else {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userID]),
      });
    }
  }

  Stream<Post> getPostById(String postId) {
    return _posts.doc(postId).snapshots().map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }
}
