import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/errors/failure_x.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/app_logo_mark.dart';
import 'package:lettuce_travel/core/widgets/demo_hint_banner.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';

/// Email + password sign-in, used only by the super admin (FR-1 in
/// docs/prd.md).
class AdminSignInScreen extends ConsumerStatefulWidget {
  const AdminSignInScreen({super.key});

  @override
  ConsumerState<AdminSignInScreen> createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends ConsumerState<AdminSignInScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'admin@lettuce.app');
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;
  bool _submitting = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.adminSignIn)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: AppSpacing.lg),
                const Center(child: AppLogoMark(size: 64, onLight: true)),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: context.l10n.adminEmailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: context.l10n.adminPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: _errorText,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.sm),
                DemoHintBanner(text: context.l10n.demoAdminHint),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.l10n.signIn),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(context.l10n.backToPhoneSignIn),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _submit() async {
    setState(() {
      _errorText = null;
      _submitting = true;
    });
    final result = await ref.read(authControllerProvider.notifier).signInAdmin(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.when(
      ok: (_) {},
      err: (failure) => setState(() => _errorText = failure.message(context)),
    );
  }
}
