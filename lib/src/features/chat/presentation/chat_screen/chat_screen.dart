import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/responsive_center.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/breakpoints.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/presentation/chat_screen/chat_screen_controller.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/presentation/job_entries_screen/job_entries_list.dart';
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
      await ref.read(chatScreenControllerProvider.notifier).submit(
            jobId: _prompt?.id,
            oldJob: _prompt,
            text: _text ?? '',
          );
      _prompt ??= Prompt(id: _text!, text: _text!);
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
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            Card(
              child: Container(
                height: chatBarHeight,
                padding: const EdgeInsets.all(Sizes.p16),
                child: _buildForm(),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_prompt != null) Expanded(child: JobEntriesList(job: _prompt!)),
                if (state.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                const SizedBox(
                  height: chatBarHeight,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() => Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Prompt'),
                keyboardAppearance: Brightness.light,
                maxLines: 2,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                initialValue: _text,
                validator: (value) => (value ?? '').isNotEmpty ? null : 'Prompt can\'t be empty',
                onSaved: (value) => _text = value,
              ),
            ),
            IconButton(
                onPressed: _submit,
                icon: const Icon(
                  Icons.send_rounded,
                  size: 20,
                ))
          ],
        ),
      );
}
