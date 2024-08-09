import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/responsive_center.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveCenter(
        maxContentWidth: 450,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'The "Test for Video 9-aug" campaign \ntriggers the above dynamic banner\nA non-dev  can with web UI modify color, image '
              '\n and the url it goes to from the eb'
              '\nIf your app supports deep links you can use those'
              '\n(although it must be https.)'
              '\n The in app messaging can at most once a day\n it can be dependent on events or audiences.\n '
              '\n Modal, Image only and cards are also supported.'
              '\n as well as two buttons for actions and some automatic analytics.',
              textAlign: TextAlign.center,
            ),
            gapH16,
          ],
        ),
      ),
    );
  }
}
