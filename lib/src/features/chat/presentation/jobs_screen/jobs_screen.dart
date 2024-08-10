import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/main.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/data/jobs_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/presentation/jobs_screen/jobs_screen_controller.dart';
import 'package:starter_architecture_flutter_firebase/src/localization/string_hardcoded.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/async_value_ui.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'.hardcoded),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            jobsScreenControllerProvider,
            (_, state) => state.showAlertDialogOnError(context),
          );
          final jobsQuery = ref.watch(jobsQueryProvider);
          return FirestoreListView<Prompt>(
            query: jobsQuery,
            emptyBuilder: (context) => const Center(child: Text('No data')),
            errorBuilder: (context, error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
            loadingBuilder: (context) => const Center(child: CircularProgressIndicator()),
            itemBuilder: (context, doc) {
              final job = doc.data();
              return Dismissible(
                key: Key('job-${job.id}'),
                background: Container(color: Colors.red),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) =>
                    ref.read(jobsScreenControllerProvider.notifier).deleteJob(job),
                child: JobListTile(
                  prompt: job,
                  onTap: () => context.goNamed(
                    AppRoute.job.name,
                    pathParameters: {'id': job.id},
                  ),
                ),
              );
            },
          );
        },
      ),
      // TODO: help text from remote config
      // floatingActionButton: FloatingActionButton.extended(
      //   icon: const Icon(Icons.help),
      //   foregroundColor: Colors.white,
      //   isExtended: true,
      //   onPressed: () async => await onHelpPressed(context),
      //   label: SizedBox(
      //     width: MediaQuery.of(context).size.width * 0.7,
      //     child: Text(helpButtonText),
      //   ),
      // ),
    );
  }

  Future<void> onHelpPressed(BuildContext context) async {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return SimpleHtmlHelpDialog(htmlString: helpScreenHtml);
        },
        fullscreenDialog: true));
  }
}

class SimpleHtmlHelpDialog extends StatelessWidget {
  final String htmlString;

  const SimpleHtmlHelpDialog({super.key, required this.htmlString});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: Html(data: htmlString));
}

class JobListTile extends StatelessWidget {
  const JobListTile({super.key, required this.prompt, this.onTap});
  final Prompt prompt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(prompt.text),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
