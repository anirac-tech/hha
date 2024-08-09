import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/app_user.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/data/entries_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry_job.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/data/jobs_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';

part 'entries_service.g.dart';

// TODO: Clean up this code a bit more
class EntriesService {
  EntriesService({required this.jobsRepository, required this.entriesRepository});
  final JobsRepository jobsRepository;
  final EntriesRepository entriesRepository;

  /// combine List<Job>, List<Entry> into List<EntryJob>
  Stream<List<EntryJob>> _allEntriesStream(UserID uid) => CombineLatestStream.combine2(
        entriesRepository.watchEntries(uid: uid),
        jobsRepository.watchPrompts(uid: uid),
        _entriesJobsCombiner,
      );

  static List<EntryJob> _entriesJobsCombiner(List<Response> entries, List<Prompt> jobs) {
    return entries.map((entry) {
      final job = jobs.firstWhere((job) => job.id == entry.promptId);
      return EntryJob(entry, job);
    }).toList();
  }
}

@riverpod
EntriesService entriesService(EntriesServiceRef ref) {
  return EntriesService(
    jobsRepository: ref.watch(jobsRepositoryProvider),
    entriesRepository: ref.watch(entriesRepositoryProvider),
  );
}
