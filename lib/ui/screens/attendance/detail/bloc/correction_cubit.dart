import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/apis/repository/attendance_repo.dart';
import '../../../../../core/apis/repository/models/attendance_correction.dart';
import '../../../../../core/services/rest_api/app_exception.dart';

enum CorrectionStatus { initial, submitting, success, failure, unauthorised }

class CorrectionState extends Equatable {
  const CorrectionState({this.status = CorrectionStatus.initial, this.message});

  final CorrectionStatus status;
  final String? message;

  @override
  List<Object?> get props => [status, message];
}

/// Submits a WinHRMS attendance correction (`POST /api/attendance-corrections`).
class CorrectionCubit extends Cubit<CorrectionState> {
  CorrectionCubit({AttendanceRepository? repository})
      : _repo = repository ?? AttendanceRepository(),
        super(const CorrectionState());

  final AttendanceRepository _repo;

  static const int minReasonLength = 10;
  static const int maxReasonLength = 2000;

  void reset() => emit(const CorrectionState());

  Future<void> submit({
    required DateTime date,
    required CorrectionType type,
    required String reason,
    String? punchIn,
    String? punchOut,
  }) async {
    if (state.status == CorrectionStatus.submitting) return;
    emit(const CorrectionState(status: CorrectionStatus.submitting));
    try {
      await _repo.submitCorrection(
          date: date,
          type: type,
          reason: reason,
          punchIn: punchIn,
          punchOut: punchOut);
      emit(const CorrectionState(
          status: CorrectionStatus.success,
          message: "Correction request submitted."));
    } on UnauthorisedException {
      emit(const CorrectionState(status: CorrectionStatus.unauthorised));
    } on AppException catch (e) {
      emit(CorrectionState(status: CorrectionStatus.failure, message: e.message));
    } catch (e) {
      emit(CorrectionState(
          status: CorrectionStatus.failure,
          message: "Couldn't submit the correction. Please try again."));
    }
  }
}
