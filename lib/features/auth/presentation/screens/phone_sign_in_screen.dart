import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/widgets/scaffold_placeholder.dart';

/// Phone number entry for parents and supervisors.
///
/// The super admin reaches email sign-in from a secondary action here, so the
/// primary path stays a single field.
class PhoneSignInScreen extends ConsumerWidget {
  const PhoneSignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const ScaffoldPlaceholder(
        title: 'Sign in',
        description:
            'Parents and bus supervisors sign in with their phone number and an '
            'SMS code. The super admin uses email and password.',
        todo: <String>[
          'Country code picker defaulting to the school country',
          'Phone field with local-format validation',
          'Send OTP via AuthRepository.sendOtp, then push the OTP screen',
          'Secondary action: admin email sign-in',
          'Language toggle (Arabic / English) available before sign-in',
        ],
      );
}
