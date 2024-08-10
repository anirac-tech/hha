import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/data/jobs_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';

part 'chat_screen_controller.g.dart';

@riverpod
class ChatScreenController extends _$ChatScreenController {
  @override
  FutureOr<void> build() {}

  Future<PromptID?> submit({PromptID? jobId, Prompt? oldJob, required String text}) async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }
    // set loading state
    state = const AsyncLoading().copyWithPrevious(state);
    final textLower = text.toLowerCase();
    // if (oldJob?.text.toLowerCase() == textLower) {
    //   state = AsyncError(Exception('Try asking a different question.'), StackTrace.current);
    //   return null;
    // }

    // check if name is already in use
    final repository = ref.read(jobsRepositoryProvider);
    final prompts = await repository.fetchPrompts(uid: currentUser.uid);
    final allLowerCaseNames = prompts.map((prompt) => prompt.text.toLowerCase()).toList();

    if (allLowerCaseNames.contains(textLower)) {
      state = AsyncError(
          'This question has been asked before. Check the History tab.', StackTrace.current);
      return null;
    } else {
      // job previously existed
      if (jobId != null) {
        final job = Prompt(id: jobId, text: text);
        state = await AsyncValue.guard(
          () => repository.updatePrompt(uid: currentUser.uid, job: job),
        );
      } else {
        state = await AsyncValue.guard(
          () => repository.addPrompt(uid: currentUser.uid, textContent: text),
        );
      }
      final newPrompts = await repository.fetchPrompts(uid: currentUser.uid);
      return newPrompts.firstWhere((prompt) => prompt.text == text).id;
    }
  }
}
