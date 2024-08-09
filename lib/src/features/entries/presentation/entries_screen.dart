import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/strings.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/cooling_center.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/presentation/entry_card.dart';

class EntriesScreen extends ConsumerWidget {
  const EntriesScreen({super.key});

  static const List<CoolingCenter> centers = [
    CoolingCenter(
        name: "Tarrant County Navigation Center",
        address: "123 Main St, Fort Worth, TX 76102",
        phone: "(817) 555-1234"),
    CoolingCenter(
        name: "Salvation Army",
        address: "456 Elm St, Arlington, TX 76010",
        phone: "(682) 555-5678"),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.centers),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(Sizes.p8),
        itemCount: centers.length,
        itemBuilder: (context, index) {
          return EntryCard(entry: centers[index]);
        },
      ),
    );
  }
}
