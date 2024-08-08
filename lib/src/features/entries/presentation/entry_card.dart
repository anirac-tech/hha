import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/cooling_center.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({super.key, required this.entry});

  final CoolingCenter entry;

  Future<void> _launchURL(
    String? url,
  ) async {
    if (url == null) return;
    if (!await canLaunchUrlString(url)) {
      log('Cannot launch $url');
    } else if (!await launchUrlString(url)) {
      throw Exception('Error launching $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p4),
        child: ListTile(
          title: Text(
            entry.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.address),
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  await _launchURL('tel:${entry.phone}');
                },
                child: Text(
                  entry.phone,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
