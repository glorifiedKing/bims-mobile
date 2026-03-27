import '../../../client/models/application_model.dart';

abstract class BcoApplicationsState {}

class BcoApplicationsInitial extends BcoApplicationsState {}

class BcoApplicationsLoading extends BcoApplicationsState {}

class BcoApplicationsLoaded extends BcoApplicationsState {
  final List<ApplicationModel> applications;
  final bool hasReachedMax;
  final int currentPage;
  final String? currentFilter;

  BcoApplicationsLoaded({
    required this.applications,
    required this.hasReachedMax,
    this.currentPage = 1,
    this.currentFilter,
  });

  BcoApplicationsLoaded copyWith({
    List<ApplicationModel>? applications,
    bool? hasReachedMax,
    int? currentPage,
    String? currentFilter,
  }) {
    return BcoApplicationsLoaded(
      applications: applications ?? this.applications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class BcoApplicationsError extends BcoApplicationsState {
  final String message;
  BcoApplicationsError(this.message);
}
