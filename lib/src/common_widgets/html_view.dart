import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlView extends StatelessWidget {
  const HtmlView(this.text, {super.key, this.style});

  final String text;
  final Style? style;

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
  Widget build(BuildContext context) => Html(
        data: text,
        onLinkTap: (url, attributes, element) => _launchURL(url),
        style: style != null ? {'*': style!} : {},
      );
}
