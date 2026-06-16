import '../../models/bco_inspection_model.dart';

abstract class BcoInspectionDetailsState {
  const BcoInspectionDetailsState();
}

class BcoInspectionDetailsInitial extends BcoInspectionDetailsState {}

class BcoInspectionDetailsLoading extends BcoInspectionDetailsState {}

class BcoInspectionDetailsLoaded extends BcoInspectionDetailsState {
  final BcoInspectionModel inspection;
  final bool isUpdating;
  final bool? updateSuccess;
  final String? updateError;

  const BcoInspectionDetailsLoaded({
    required this.inspection,
    this.isUpdating = false,
    this.updateSuccess,
    this.updateError,
  });

  BcoInspectionDetailsLoaded copyWith({
    BcoInspectionModel? inspection,
    bool? isUpdating,
    bool? updateSuccess,
    String? updateError,
  }) {
    return BcoInspectionDetailsLoaded(
      inspection: inspection ?? this.inspection,
      isUpdating: isUpdating ?? this.isUpdating,
      updateSuccess: updateSuccess,
      updateError: updateError,
    );
  }
}

class BcoInspectionDetailsError extends BcoInspectionDetailsState {
  final String message;
  const BcoInspectionDetailsError(this.message);
}
