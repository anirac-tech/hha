import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/app_user.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/data/entries_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/domain/job.dart';

part 'jobs_repository.g.dart';

class JobsRepository {
  const JobsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  // TODO: Carefully rename job to prompt
  static String jobPath(String uid, String jobId) => 'users/$uid/prompts/$jobId';
  static String jobsPath(String uid) => 'users/$uid/prompts';

  // TODO: caseNotes path for caseNotes
  /*
  static String jobPath(String uid, String jobId) => 'users/$uid/jobs/$jobId';
  static String jobsPath(String uid) => 'users/$uid/jobs';


   */

  static String entriesPath(String uid) => EntriesRepository.entriesPath(uid);

  // create
  Future<void> addJob({required UserID uid, required String textContent}) =>
      _firestore.collection(jobsPath(uid)).add({
        'text': textContent,
      });

  // TODO: Delete update and deleteJob
  // update
  Future<void> updateJob({required UserID uid, required Prompt job}) =>
      _firestore.doc(jobPath(uid, job.id)).update(job.toMap());

  // delete
  Future<void> deleteJob({required UserID uid, required PromptID promptId}) async {
    // delete where entry.jobId == job.jobId
    final entriesRef = _firestore.collection(entriesPath(uid));
    final entries = await entriesRef.get();
    for (final snapshot in entries.docs) {
      final entry = Response.fromMap(snapshot.data(), snapshot.id);
      if (entry.promptId == promptId) {
        await snapshot.reference.delete();
      }
    }
    // delete job
    final jobRef = _firestore.doc(jobPath(uid, promptId));
    await jobRef.delete();
  }

  // read
  Stream<Prompt> watchJob({required UserID uid, required PromptID jobId}) => _firestore
      .doc(jobPath(uid, jobId))
      .withConverter<Prompt>(
        fromFirestore: (snapshot, _) => Prompt.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (job, _) => job.toMap(),
      )
      .snapshots()
      .map((snapshot) => snapshot.data()!);

  Stream<List<Prompt>> watchJobs({required UserID uid}) => queryJobs(uid: uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Query<Prompt> queryJobs({required UserID uid}) =>
      _firestore.collection(jobsPath(uid)).withConverter(
            fromFirestore: (snapshot, _) => Prompt.fromMap(snapshot.data()!, snapshot.id),
            toFirestore: (job, _) => job.toMap(),
          );

  Future<List<Prompt>> fetchJobs({required UserID uid}) async {
    final jobs = await queryJobs(uid: uid).get();
    return jobs.docs.map((doc) => doc.data()).toList();
  }
}

@Riverpod(keepAlive: true)
JobsRepository jobsRepository(JobsRepositoryRef ref) {
  return JobsRepository(FirebaseFirestore.instance);
}

// JOB=Ai PROMPT.
// TODO: renaming, carefully or with ai

@riverpod
Query<Prompt> jobsQuery(JobsQueryRef ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final repository = ref.watch(jobsRepositoryProvider);
  return repository.queryJobs(uid: user.uid);
}

@riverpod
Stream<Prompt> jobStream(JobStreamRef ref, PromptID jobId) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final repository = ref.watch(jobsRepositoryProvider);
  return repository.watchJob(uid: user.uid, jobId: jobId);
}
