import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/data/jobs_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/domain/job.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/presentation/edit_job_screen/job_submit_exception.dart';

part 'edit_job_screen_controller.g.dart';

@riverpod
class EditJobScreenController extends _$EditJobScreenController {
  @override
  FutureOr<void> build() {
    //
  }

  Future<bool> submit({PromptID? jobId, Prompt? oldJob, required String text}) async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }
    // set loading state
    state = const AsyncLoading().copyWithPrevious(state);
    // check if name is already in use
    final repository = ref.read(jobsRepositoryProvider);
    final jobs = await repository.fetchJobs(uid: currentUser.uid);
    final allLowerCaseNames = jobs.map((job) => job.text.toLowerCase()).toList();
    // it's ok to use the same name as the old job
    if (oldJob != null) {
      allLowerCaseNames.remove(oldJob.text.toLowerCase());
    }
    // check if name is already used
    if (allLowerCaseNames.contains(text.toLowerCase())) {
      state = AsyncError(JobSubmitException(), StackTrace.current);
      return false;
    } else {
      // job previously existed
      if (jobId != null) {
        final job = Prompt(id: jobId, text: text);
        state = await AsyncValue.guard(
          () => repository.updateJob(uid: currentUser.uid, job: job),
        );
      } else {
        state = await AsyncValue.guard(
          () => repository.addJob(uid: currentUser.uid, textContent: text),
        );
      }
      return state.hasError == false;
    }
  }
}
