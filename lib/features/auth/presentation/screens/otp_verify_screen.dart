import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/widgets/scaffold_placeholder.dart';

/// SMS code entry.
class OtpVerifyScreen extends ConsumerWidget {
  const OtpVerifyScreen({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ScaffoldPlaceholder(
        title: 'Verify',
        description: 'Enter the code sent to $phoneNumber.',
        todo: const <String>[
          'Six-box OTP input with auto-advance and paste support',
          'Resend timer (60s) and resend action',
          'Verify via AuthRepository.verifyOtp; router redirects by role',
          'Map Firebase auth errors onto localized failure messages',
        ],
      );
}
