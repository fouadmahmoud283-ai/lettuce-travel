import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/errors/failure_x.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';

/// SMS code entry: six digit boxes with auto-advance, and a 60-second resend
/// timer.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  static const int _codeLength = 6;
  final List<TextEditingController> _controllers =
      List<TextEditingController>.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List<FocusNode>.generate(_codeLength, (_) => FocusNode());

  bool _submitting = false;
  String? _errorText;
  int _resendSeconds = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      setState(() => _resendSeconds--);
      if (_resendSeconds <= 0) timer.cancel();
    });
  }

  String get _code => _controllers.map((TextEditingController c) => c.text).join();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(context.l10n.verificationCode, style: context.text.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.otpSentTo(widget.phoneNumber),
                  style: context.text.bodyMedium
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    for (int i = 0; i < _codeLength; i++) _digitBox(i),
                  ],
                ),
                if (_errorText != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_errorText!, style: TextStyle(color: context.colors.error)),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _submitting ? null : _verify,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.l10n.verify),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton(
                    onPressed: _resendSeconds > 0 ? null : _resend,
                    child: Text(
                      _resendSeconds > 0
                          ? context.l10n.resendCodeIn(_resendSeconds)
                          : context.l10n.resendCode,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _digitBox(int index) => SizedBox(
        width: 44,
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: context.text.titleLarge,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(counterText: ''),
          onChanged: (String value) {
            if (value.isNotEmpty && index < _codeLength - 1) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            if (_code.length == _codeLength) _verify();
          },
        ),
      );

  Future<void> _verify() async {
    if (_code.length != _codeLength) {
      setState(() => _errorText = context.l10n.otpInvalid);
      return;
    }
    setState(() {
      _errorText = null;
      _submitting = true;
    });
    final result = await ref.read(authControllerProvider.notifier).verifyOtp(_code);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.when(
      ok: (_) {},
      err: (failure) => setState(() => _errorText = failure.message(context)),
    );
  }

  Future<void> _resend() async {
    await ref.read(authControllerProvider.notifier).sendOtp(widget.phoneNumber);
    if (!mounted) return;
    _startResendTimer();
  }
}
