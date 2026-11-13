import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/apis/repository/models/attendance_correction.dart';
import '../../../../../core/apis/repository/models/monthly_attendance.dart';
import '../../../../../core/config/config.dart';
import '../../../../../core/utils/server_time.dart';
import '../bloc/correction_cubit.dart';

/// Correction status for a day plus the "Request correction" action.
class CorrectionView extends StatelessWidget {
  const CorrectionView({
    super.key,
    required this.date,
    this.day,
    this.existing,
    this.onSubmitted,
  });

  final DateTime date;
  final AttendanceDay? day;
  final AttendanceCorrection? existing;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final AttendanceCorrection? c = existing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (c != null) _statusCard(context, c),
        if (c == null || !c.isPending)
          OutlinedButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.edit_calendar_outlined, size: 18),
            label: Text(c == null ? "Request correction" : "Request again"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.colorAccent,
              side: const BorderSide(color: AppColors.colorAccent),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
      ],
    );
  }

  Widget _statusCard(BuildContext context, AttendanceCorrection c) {
    final (Color fg, Color bg, String label) = switch (c.status) {
      "approved" => (AppColors.approve, AppColors.approveLight, "Approved"),
      "rejected" => (AppColors.reject, AppColors.rejectLight, "Rejected"),
      _ => (AppColors.pending, AppColors.pendingLight, "Pending review"),
    };
    String? times;
    if (c.requestedPunchInAt != null || c.requestedPunchOutAt != null) {
      final inT = c.requestedPunchInAt == null
          ? "–"
          : ServerTime.istHhMm(c.requestedPunchInAt!);
      final outT = c.requestedPunchOutAt == null
          ? "–"
          : ServerTime.istHhMm(c.requestedPunchOutAt!);
      times = "Requested: $inT → $outT";
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.edit_note, size: 18, color: fg),
            const SizedBox(width: 6),
            Text("Correction · $label",
                style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
          ]),
          if (times != null) ...[
            const SizedBox(height: 6),
            Text(times, style: const TextStyle(fontSize: 13)),
          ],
          const SizedBox(height: 4),
          Text(c.reason,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.darkGrey)),
          if ((c.reviewNotes ?? "").isNotEmpty) ...[
            const SizedBox(height: 4),
            Text("Note: ${c.reviewNotes}",
                style: const TextStyle(fontSize: 13, color: AppColors.darkGrey)),
          ],
        ],
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    final cubit = context.read<CorrectionCubit>()..reset();
    final bool? sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _CorrectionForm(date: date, day: day),
      ),
    );
    if (sent == true) onSubmitted?.call();
  }
}

class _CorrectionForm extends StatefulWidget {
  const _CorrectionForm({required this.date, this.day});

  final DateTime date;
  final AttendanceDay? day;

  @override
  State<_CorrectionForm> createState() => _CorrectionFormState();
}

class _CorrectionFormState extends State<_CorrectionForm> {
  final TextEditingController _reason = TextEditingController();
  CorrectionType _type = CorrectionType.both;
  TimeOfDay? _in;
  TimeOfDay? _out;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-fill with the recorded punches (IST), like the web app.
    _in = _time(widget.day?.punchInAt);
    _out = _time(widget.day?.punchOutAt);
  }

  TimeOfDay? _time(DateTime? instant) {
    if (instant == null) return null;
    final t = ServerTime.toIst(instant);
    return TimeOfDay(hour: t.hour, minute: t.minute);
  }

  String _hhmm(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isIn) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isIn ? _in : _out) ??
          (isIn
              ? const TimeOfDay(hour: 9, minute: 0)
              : const TimeOfDay(hour: 18, minute: 0)),
    );
    if (picked != null) setState(() => isIn ? _in = picked : _out = picked);
  }

  void _submit() {
    final String reason = _reason.text.trim();
    String? err;
    if (_type.needsIn && _in == null) {
      err = "Pick the corrected punch-in time.";
    } else if (_type.needsOut && _out == null) {
      err = "Pick the corrected punch-out time.";
    } else if (reason.length < CorrectionCubit.minReasonLength) {
      err = "Please explain the correction in at least "
          "${CorrectionCubit.minReasonLength} characters.";
    }
    setState(() => _error = err);
    if (err != null) return;
    FocusScope.of(context).unfocus();
    context.read<CorrectionCubit>().submit(
          date: widget.date,
          type: _type,
          reason: reason,
          punchIn: _in == null ? null : _hhmm(_in!),
          punchOut: _out == null ? null : _hhmm(_out!),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CorrectionCubit, CorrectionState>(
      listener: (context, state) {
        if (state.status == CorrectionStatus.success) {
          AppHelper.showSnackBar(context,
              snackBarMode: SnackBarMode.success,
              content: state.message ?? "Correction request submitted.");
          Navigator.of(context).pop(true);
        } else if (state.status == CorrectionStatus.failure) {
          setState(() => _error = state.message);
        } else if (state.status == CorrectionStatus.unauthorised) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.login, (r) => false);
        }
      },
      builder: (context, state) {
        final bool busy = state.status == CorrectionStatus.submitting;
        return Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(3))),
                ),
                const SizedBox(height: 16),
                Text("Request correction",
                    style: Theme.of(context).textTheme.largeXValue),
                const SizedBox(height: 4),
                Text(AppHelper.dateFormat(date: widget.date, format: 'EEEE, d MMMM y'),
                    style: const TextStyle(color: AppColors.lightGray)),
                const SizedBox(height: 16),
                const Text("What needs correcting?",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in CorrectionType.values)
                      ChoiceChip(
                        label: Text(t.label),
                        selected: _type == t,
                        onSelected: busy ? null : (_) => setState(() => _type = t),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(children: [
                  if (_type.needsIn)
                    Expanded(child: _timeTile("Punch in (IST)", _in, () => _pick(true))),
                  if (_type.needsIn && _type.needsOut) const SizedBox(width: 12),
                  if (_type.needsOut)
                    Expanded(child: _timeTile("Punch out (IST)", _out, () => _pick(false))),
                ]),
                const SizedBox(height: 16),
                TextField(
                  controller: _reason,
                  enabled: !busy,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: CorrectionCubit.maxReasonLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: "Reason",
                    hintText: "e.g. Forgot to punch out, left at 6:30 PM",
                    border: OutlineInputBorder(),
                    counterText: "",
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: AppColors.reject)),
                ],
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : () => Navigator.of(context).pop(false),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: busy ? null : _submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.colorAccent,
                          foregroundColor: Colors.white),
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text("Submit"),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _timeTile(String label, TimeOfDay? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.schedule, size: 20),
        ),
        child: Text(value == null ? "Select" : value.format(context)),
      ),
    );
  }
}
