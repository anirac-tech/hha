import 'dart:async';

import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/responsive_center.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/breakpoints.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/data/jobs_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/presentation/chat_screen/chat_screen_controller.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/presentation/job_entries_screen/entry_list_item.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/data/entries_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/async_value_ui.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _formKey = GlobalKey<FormState>();
  static const double chatBarHeight = 128;

  Prompt? _prompt;
  String? _text;

  @override
  void initState() {
    super.initState();
    if (_prompt != null) {
      _text = _prompt!.text;
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      final id = await ref.read(chatScreenControllerProvider.notifier).submit(
            jobId: null,
            oldJob: _prompt,
            text: _text ?? '',
          );
      if (id != null) setState(() => _prompt = Prompt(id: id, text: _text!));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      chatScreenControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(chatScreenControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: <Widget>[
          TextButton(
            onPressed: state.isLoading
                ? null
                : () => context.goNamed(
                      AppRoute.jobs.name,
                    ),
            child: const Text(
              'History',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: ResponsiveCenter(
        maxContentWidth: Breakpoint.tablet,
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(Sizes.p4),
                child: (_prompt != null)
                    ? _buildResponseView()
                    : Text(
                        'What can we help with today?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: Sizes.p48,
                            ),
                      ),
              ),
            ),
            Card(
              child: Container(
                constraints: const BoxConstraints(maxHeight: chatBarHeight),
                padding: const EdgeInsets.all(Sizes.p16),
                child: _buildForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseView() {
    final jobEntriesQuery = ref.watch(jobEntriesQueryProvider(_prompt!.id));
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Text(
              '"${_prompt!.text}"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ),
        Expanded(
          child: FirestoreListView<Response>(
            query: jobEntriesQuery,
            emptyBuilder: (context) => const Center(child: Text('No response yet')),
            errorBuilder: (context, error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
            loadingBuilder: (context) => const CircularProgressIndicator.adaptive(),
            itemBuilder: (context, doc) {
              final entry = doc.data();
              return Html(
                data: entry.response,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForm() => Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                    hintText: "Ask a question...",
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none),
                keyboardAppearance: Brightness.light,
                minLines: 1,
                maxLines: 3,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                initialValue: _text,
                validator: (value) {
                  if ((value ?? '').isEmpty) return 'Prompt can\'t be empty';
                  if (value == _prompt?.text) return 'Try asking a new question';
                  return null;
                },
                onSaved: (value) => _text = value,
              ),
            ),
            FloatingActionButton(
              onPressed: _submit,
              shape: const CircleBorder(),
              backgroundColor: Colors.blue,
              splashColor: Colors.blue[200],
              elevation: 0,
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      );
}
