import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_architecture_flutter_firebase/src/app.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/onboarding/data/onboarding_repository.dart';

import 'src/mocks.dart';

final mockApp = ProviderScope(overrides: [
  authRepositoryProvider.overrideWithValue(MockAuthRepository()),
  firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
  onboardingRepositoryProvider.overrideWith((ref) => MockOnboardingRepository()),
], child: const MyApp());

extension PumpTestApp on WidgetTester {
  Future<void> pumpApp() => pumpWidget(mockApp);
}
