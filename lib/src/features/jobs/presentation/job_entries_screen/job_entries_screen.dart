import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/async_value_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/data/jobs_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/domain/job.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/presentation/job_entries_screen/job_entries_list.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class PromptResponsesScreen extends ConsumerWidget {
  const PromptResponsesScreen({super.key, required this.promptId});
  final PromptID promptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ScaffoldAsyncValueWidget<Prompt>(
        value: ref.watch(jobStreamProvider(promptId)),
        data: (job) => JobEntriesPageContents(job: job),
      );
}

class JobEntriesPageContents extends StatelessWidget {
  const JobEntriesPageContents({super.key, required this.job});
  final Prompt job;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(job.text),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => context.goNamed(
                AppRoute.editJob.name,
                pathParameters: {'id': job.id},
                extra: job,
              ),
            ),
          ],
        ),
        body: JobEntriesList(job: job),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => context.goNamed(
            AppRoute.addEntry.name,
            pathParameters: {'id': job.id},
            extra: job,
          ),
        ),
      );
}
