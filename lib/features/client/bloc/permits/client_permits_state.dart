import '../../models/permit_model.dart';

abstract class ClientPermitsState {}

class ClientPermitsInitial extends ClientPermitsState {}

class ClientPermitsLoading extends ClientPermitsState {}

class ClientPermitsLoaded extends ClientPermitsState {
  final List<PermitModel> permits;
  final bool hasReachedMax;
  final String? searchQuery;

  ClientPermitsLoaded({
    required this.permits,
    this.hasReachedMax = false,
    this.searchQuery,
  });

  ClientPermitsLoaded copyWith({
    List<PermitModel>? permits,
    bool? hasReachedMax,
    String? searchQuery,
  }) {
    return ClientPermitsLoaded(
      permits: permits ?? this.permits,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ClientPermitsError extends ClientPermitsState {
  final String message;

  ClientPermitsError(this.message);
}
