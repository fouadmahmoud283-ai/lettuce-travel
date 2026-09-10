import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/errors/failure_x.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/features/attendance/data/repositories/fake_attendance_repository.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/absence_notice.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lettuce_travel/features/parent/presentation/controllers/parent_child_controller.dart';

class ParentAbsenceScreen extends ConsumerStatefulWidget {
  const ParentAbsenceScreen({required this.studentId, super.key});

  final String studentId;

  @override
  ConsumerState<ParentAbsenceScreen> createState() => _ParentAbsenceScreenState();
}

class _ParentAbsenceScreenState extends ConsumerState<ParentAbsenceScreen> {
  DateTime _date = DateTime.now();
  AbsenceScope _scope = AbsenceScope.wholeDay;
  final TextEditingController _reasonController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.reportAbsence)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: <Widget>[
              Material(
                color: context.colors.surface,
                elevation: 1,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: ListTile(
                  leading: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: context.colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(context.l10n.selectDate),
                  subtitle: Text(_date.toServiceDate()),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: RadioGroup<AbsenceScope>(
                  groupValue: _scope,
                  onChanged: (AbsenceScope? v) => setState(() => _scope = v!),
                  child: Column(
                    children: <Widget>[
                      RadioListTile<AbsenceScope>(
                        title: Text(context.l10n.absenceScopeWholeDay),
                        value: AbsenceScope.wholeDay,
                      ),
                      RadioListTile<AbsenceScope>(
                        title: Text(context.l10n.absenceScopeMorningOnly),
                        value: AbsenceScope.morningOnly,
                      ),
                      RadioListTile<AbsenceScope>(
                        title: Text(context.l10n.absenceScopeAfternoonOnly),
                        value: AbsenceScope.afternoonOnly,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _reasonController,
                maxLines: 2,
                decoration: InputDecoration(hintText: context.l10n.absenceReasonHint),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.save),
              ),
            ],
          ),
        ),
      );

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final String? guardianId = ref.read(authControllerProvider).user?.id;
    final String? schoolId =
        ref.read(parentStudentProvider(widget.studentId)).asData?.value?.schoolId;
    if (guardianId == null || schoolId == null) return;

    setState(() => _submitting = true);
    final result = await ref.read(attendanceRepositoryProvider).reportAbsence(
          AbsenceNotice(
            id: '',
            schoolId: schoolId,
            studentId: widget.studentId,
            serviceDate: _date.toServiceDate(),
            scope: _scope,
            reportedBy: guardianId,
            reason: _reasonController.text.trim(),
            createdAt: DateTime.now(),
          ),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.when(
      ok: (_) {
        context.pop();
        context.showSnack(context.l10n.absenceSubmitted);
      },
      err: (failure) => context.showSnack(failure.message(context), isError: true),
    );
  }
}
