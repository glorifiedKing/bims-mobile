import '../../models/pro_application_model.dart';

abstract class ProfessionalApplicationsState {}

class ProfessionalApplicationsInitial extends ProfessionalApplicationsState {}

class ProfessionalApplicationsLoading extends ProfessionalApplicationsState {}

class ProfessionalApplicationsLoaded extends ProfessionalApplicationsState {
  final List<ProApplicationModel> applications;
  final bool hasReachedMax;
  final int currentPage;
  final String currentFilter;

  ProfessionalApplicationsLoaded({
    required this.applications,
    required this.hasReachedMax,
    required this.currentPage,
    required this.currentFilter,
  });

  ProfessionalApplicationsLoaded copyWith({
    List<ProApplicationModel>? applications,
    bool? hasReachedMax,
    int? currentPage,
    String? currentFilter,
  }) {
    return ProfessionalApplicationsLoaded(
      applications: applications ?? this.applications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class ProfessionalApplicationsError extends ProfessionalApplicationsState {
  final String message;

  ProfessionalApplicationsError(this.message);
}
