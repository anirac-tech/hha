import 'package:equatable/equatable.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';

class EntryJob extends Equatable {
  const EntryJob(this.entry, this.job);

  final Response entry;
  final Prompt job;

  @override
  List<Object?> get props => [entry, job];

  @override
  bool? get stringify => true;
}
