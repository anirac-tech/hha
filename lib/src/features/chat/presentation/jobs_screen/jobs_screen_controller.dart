import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/data/jobs_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';

part 'jobs_screen_controller.g.dart';

@riverpod
class JobsScreenController extends _$JobsScreenController {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> deleteJob(Prompt job) async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }
    final repository = ref.read(jobsRepositoryProvider);
    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => repository.deleteJob(uid: currentUser.uid, promptId: job.id));
  }
}