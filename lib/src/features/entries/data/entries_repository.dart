import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/app_user.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';

class EntriesRepository {
  const EntriesRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String entryPath(String uid, String entryId) => 'users/$uid/responses/$entryId';
  static String entriesPath(String uid) => 'users/$uid/responses';

  // create
  Future<void> addEntry({
    required UserID uid,
    required PromptID promptId,
    required DateTime dateTime,
    required String response,
  }) =>
      _firestore.collection(entriesPath(uid)).add({
        'promptId': promptId,
        'dateTime': dateTime.millisecondsSinceEpoch,
        'response': response,
      });

  // update
  Future<void> updateEntry({
    required UserID uid,
    required Response entry,
  }) =>
      _firestore.doc(entryPath(uid, entry.id)).update(entry.toMap());

  // delete
  Future<void> deleteEntry({required UserID uid, required ResponseID entryId}) =>
      _firestore.doc(entryPath(uid, entryId)).delete();

  // read
  Stream<List<Response>> watchEntries({required UserID uid, PromptID? promptId}) =>
      queryEntries(uid: uid, promptId: promptId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Query<Response> queryEntries({required UserID uid, PromptID? promptId}) {
    Query<Response> query = _firestore.collection(entriesPath(uid)).withConverter<Response>(
          fromFirestore: (snapshot, _) => Response.fromMap(snapshot.data()!, snapshot.id),
          toFirestore: (entry, _) => entry.toMap(),
        );
    if (promptId != null) {
      query = query.where('promptId', isEqualTo: promptId);
    }
    return query;
  }
}

final entriesRepositoryProvider = Provider<EntriesRepository>((ref) {
  return EntriesRepository(FirebaseFirestore.instance);
});

final jobEntriesQueryProvider =
    Provider.autoDispose.family<Query<Response>, PromptID>((ref, promptId) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null when fetching jobs');
  }
  final repository = ref.watch(entriesRepositoryProvider);
  return repository.queryEntries(uid: user.uid, promptId: promptId);
});
