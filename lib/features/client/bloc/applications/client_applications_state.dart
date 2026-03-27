import '../../models/application_model.dart';

abstract class ClientApplicationsState {}

class ClientApplicationsInitial extends ClientApplicationsState {}

class ClientApplicationsLoading extends ClientApplicationsState {}

class ClientApplicationsLoaded extends ClientApplicationsState {
  final List<ApplicationModel> applications;
  final bool hasReachedMax;
  final String selectedFilter;

  ClientApplicationsLoaded({
    required this.applications,
    this.hasReachedMax = false,
    this.selectedFilter = 'ALL',
  });

  ClientApplicationsLoaded copyWith({
    List<ApplicationModel>? applications,
    bool? hasReachedMax,
    String? selectedFilter,
  }) {
    return ClientApplicationsLoaded(
      applications: applications ?? this.applications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class ClientApplicationsError extends ClientApplicationsState {
  final String message;

  ClientApplicationsError(this.message);
}
