import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/responsive_center.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/breakpoints.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/presentation/edit_job_screen/edit_job_screen_controller.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/async_value_ui.dart';

class EditJobScreen extends ConsumerStatefulWidget {
  const EditJobScreen({super.key, this.promptId, this.prompt});
  final PromptID? promptId;
  final Prompt? prompt;

  @override
  ConsumerState<EditJobScreen> createState() => _EditJobPageState();
}

class _EditJobPageState extends ConsumerState<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _text;

  @override
  void initState() {
    super.initState();
    if (widget.prompt != null) {
      _text = widget.prompt?.text;
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
      final success = await ref.read(editJobScreenControllerProvider.notifier).submit(
            jobId: widget.promptId,
            oldJob: widget.prompt,
            text: _text ?? '',
          );
      if (success && mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      editJobScreenControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(editJobScreenControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prompt == null ? 'New Prompt' : 'Edit Job (should we remove this?)'),
        actions: <Widget>[
          TextButton(
            onPressed: state.isLoading ? null : _submit,
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: _buildContents(),
    );
  }

  Widget _buildContents() => SingleChildScrollView(
        child: ResponsiveCenter(
          maxContentWidth: Breakpoint.tablet,
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildForm(),
            ),
          ),
        ),
      );

  Widget _buildForm() => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildFormChildren(),
        ),
      );

  List<Widget> _buildFormChildren() => [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Prompt'),
          keyboardAppearance: Brightness.light,
          maxLines: 7,
          maxLengthEnforcement: MaxLengthEnforcement.none,
          initialValue: _text,
          validator: (value) => (value ?? '').isNotEmpty ? null : 'Prompt can\'t be empty',
          onSaved: (value) => _text = value,
        ),
      ];
}
