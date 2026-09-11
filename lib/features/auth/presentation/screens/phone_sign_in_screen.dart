import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/localization/locale_controller.dart';
import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/errors/failure_x.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/app_logo_mark.dart';
import 'package:lettuce_travel/core/widgets/bus_illustration.dart';
import 'package:lettuce_travel/core/widgets/demo_hint_banner.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';

/// Phone number entry for parents and supervisors.
///
/// The super admin reaches email sign-in from a secondary action here, so the
/// primary path stays a single field.
class PhoneSignInScreen extends ConsumerStatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  ConsumerState<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends ConsumerState<PhoneSignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorText;
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.language_rounded),
              tooltip: context.l10n.language,
              onPressed: () => ref.read(localeControllerProvider.notifier).toggle(),
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: const DecorativeBlobs(
                colors: <Color>[AppColors.primary, AppColors.tertiary],
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Center(
                          child: Hero(
                            tag: AppLogoMark.heroTag,
                            child: AppLogoMark(size: 76, onLight: true),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          context.l10n.welcomeTitle,
                          style:
                              context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          context.l10n.welcomeSubtitle,
                          style: context.text.bodyMedium
                              ?.copyWith(color: context.colors.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          decoration: InputDecoration(
                            labelText: context.l10n.phoneNumber,
                            hintText: context.l10n.phoneHint,
                            prefixIcon: const Icon(Icons.phone_outlined),
                            errorText: _errorText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DemoHintBanner(text: context.l10n.demoPhoneHint),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(context.l10n.sendCode),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: () => context.push(RoutePaths.adminSignIn),
                          child: Text(context.l10n.adminSignIn),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _submit() async {
    final String phone = _phoneController.text.trim();
    if (phone.length < 8) {
      setState(() => _errorText = context.l10n.invalidPhone);
      return;
    }
    setState(() {
      _errorText = null;
      _submitting = true;
    });
    final result = await ref.read(authControllerProvider.notifier).sendOtp(phone);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.when(
      ok: (_) => context.push('${RoutePaths.otpVerify}?phone=$phone'),
      err: (failure) => context.showSnack(failure.message(context), isError: true),
    );
  }
}
