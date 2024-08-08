import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/strings.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/cooling_center.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EntriesScreen extends ConsumerWidget {
  const EntriesScreen({super.key});

  static const List<CoolingCenter> centers = [
    CoolingCenter(
        name: "Tarrant County Navigation Center",
        address: "123 Main St, Fort Worth, TX 76102",
        phone: "<a href='tel:8175551234'>(817) 555-1234</a>"),
    CoolingCenter(
        name: "Salvation Army",
        address: "456 Elm St, Arlington, TX 76010",
        phone: "<a href='tel:6825555678'>(682) 555-5678</a>"),
  ];

  void _onTap(
    String? url,
    Map<String, String> attributes,
    Element? element,
  ) async {
    if (url == null) return;
    if (!await canLaunchUrlString(url)) {
      log('Cannot launch $url');
    }
    if (!await launchUrlString(url)) {
      throw Exception('Error launching $url');
    }
  }

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
          return Card(
            child: ListTile(
              title: Text(centers[index].name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(centers[index].address),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone,
                        size: Sizes.p16,
                      ),
                      Expanded(
                        child: Html(
                          data: centers[index].phone,
                          onLinkTap: (url, attributes, element) => _onTap,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
