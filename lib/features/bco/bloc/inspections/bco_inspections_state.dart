import '../../models/bco_inspection_model.dart';

abstract class BcoInspectionsState {
  const BcoInspectionsState();
}

class BcoInspectionsInitial extends BcoInspectionsState {}

class BcoInspectionsLoading extends BcoInspectionsState {}

class BcoInspectionsLoaded extends BcoInspectionsState {
  final List<BcoInspectionModel> inspections;
  final bool hasReachedMax;
  final int currentPage;
  final int? currentTypeId;
  final int? currentStatusId;
  final String? currentStart;
  final String? currentEnd;

  const BcoInspectionsLoaded({
    required this.inspections,
    required this.hasReachedMax,
    required this.currentPage,
    this.currentTypeId,
    this.currentStatusId,
    this.currentStart,
    this.currentEnd,
  });

  BcoInspectionsLoaded copyWith({
    List<BcoInspectionModel>? inspections,
    bool? hasReachedMax,
    int? currentPage,
    int? currentTypeId,
    int? currentStatusId,
    String? currentStart,
    String? currentEnd,
  }) {
    return BcoInspectionsLoaded(
      inspections: inspections ?? this.inspections,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentTypeId: currentTypeId ?? this.currentTypeId,
      currentStatusId: currentStatusId ?? this.currentStatusId,
      currentStart: currentStart ?? this.currentStart,
      currentEnd: currentEnd ?? this.currentEnd,
    );
  }
}

class BcoInspectionsError extends BcoInspectionsState {
  final String message;
  const BcoInspectionsError(this.message);
}
