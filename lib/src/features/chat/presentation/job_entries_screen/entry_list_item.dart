import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/format.dart';

class EntryListItem extends StatelessWidget {
  const EntryListItem({
    super.key,
    required this.entry,
    required this.job,
    this.onTap,
  });

  final Response entry;
  final Prompt job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.p16,
          vertical: Sizes.p8,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _buildContents(context),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final dayOfWeek = Format.dayOfWeek(entry.dateTime);
    final startDate = Format.date(entry.dateTime);
    final startTime = TimeOfDay.fromDateTime(entry.dateTime).format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: <Widget>[
          Text(dayOfWeek, style: const TextStyle(fontSize: 18.0, color: Colors.grey)),
          gapW16,
          Text(startDate, style: const TextStyle(fontSize: 18.0)),
          gapW16,
          Text(startTime, style: const TextStyle(fontSize: 18.0)),
        ]),
        if (entry.response.isNotEmpty)
          Text(
            entry.response,
            style: const TextStyle(fontSize: 12.0),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );
  }
}

class DismissibleEntryListItem extends StatelessWidget {
  const DismissibleEntryListItem({
    super.key,
    required this.dismissibleKey,
    required this.entry,
    required this.job,
    this.onDismissed,
    this.onTap,
  });

  final Key dismissibleKey;
  final Response entry;
  final Prompt job;
  final VoidCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: dismissibleKey,
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDismissed?.call(),
      child: EntryListItem(
        entry: entry,
        job: job,
        onTap: onTap,
      ),
    );
  }
}
