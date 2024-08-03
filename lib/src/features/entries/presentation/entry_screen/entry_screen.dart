import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/date_time_picker.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/responsive_center.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/breakpoints.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/presentation/entry_screen/entry_screen_controller.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/domain/job.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/async_value_ui.dart';

// Important note: this entire "responses" page is for demo/testing
class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, required this.promptID, this.responseID, this.response});
  final PromptID promptID;
  final ResponseID? responseID;
  final Response? response;

  @override
  ConsumerState<EntryScreen> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryScreen> {
  late DateTime _date;

  TimeOfDay _timeOfDay = const TimeOfDay(hour: 11, minute: 22);

  late String _response;

  DateTime get dateTime => DateTime(_date.year, _date.month, _date.day, 6, 22);

  @override
  void initState() {
    super.initState();
    final start = widget.response?.dateTime ?? DateTime.now();
    _date = DateTime(start.year, start.month, start.day);

    _response = widget.response?.response ?? '';
  }

  Future<void> _setEntryAndDismiss() async {
    final success = await ref.read(entryScreenControllerProvider.notifier).submit(
          entryId: widget.responseID,
          jobId: widget.promptID,
          dateTime: dateTime,
          response: _response,
        );
    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      entryScreenControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.response != null ? 'Edit Pretend Response' : 'New Pretend Response'),
        actions: <Widget>[
          TextButton(
            child: Text(
              widget.response != null ? 'Update' : 'Create',
              style: const TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            onPressed: () => _setEntryAndDismiss(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxContentWidth: Breakpoint.tablet,
          padding: const EdgeInsets.all(Sizes.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildStartDate(),
              gapH8,
              _buildTemporaryAnswer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartDate() => DateTimePicker(
        labelText: 'Time',
        selectedDate: _date,
        selectedTime: _timeOfDay,
        onSelectedDate: (date) => setState(() => _date = date),
        onSelectedTime: (time) => setState(() => _timeOfDay = time),
      );

  Widget _buildTemporaryAnswer() => Expanded(
        child: TextField(
          keyboardType: TextInputType.multiline,
          maxLengthEnforcement: MaxLengthEnforcement.none,
          controller: TextEditingController(text: _response),
          decoration: const InputDecoration(
            labelText:
                'Please copy/paste/export answer from gemini.google.com\n possibly as plain text or html eetc',
            labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
          keyboardAppearance: Brightness.light,
          style: const TextStyle(fontSize: 20.0, color: Colors.black),
          // https://g.co/gemini/share/4305521712af
          // re: full width considerations with keyboard etc
          // expanded+null didn't "jus twork" but this is a temporary screen
          maxLines: 24,
          onChanged: (pretendAnswer) => _response = pretendAnswer,
        ),
      );
}
