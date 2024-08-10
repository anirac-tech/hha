import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/async_value_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/data/jobs_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/presentation/job_entries_screen/job_entries_list.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class PromptResponsesScreen extends ConsumerWidget {
  const PromptResponsesScreen({super.key, required this.promptId});
  final PromptID promptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ScaffoldAsyncValueWidget<Prompt>(
        value: ref.watch(jobStreamProvider(promptId)),
        data: (job) => JobEntriesPageContents(prompt: job),
      );
}

class JobEntriesPageContents extends StatelessWidget {
  const JobEntriesPageContents({super.key, required this.prompt});
  final Prompt prompt;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(prompt.text),
        ),
        body: JobEntriesList(job: prompt),
      );
}
