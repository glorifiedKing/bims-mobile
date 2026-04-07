import '../../models/express_penalty_model.dart';

abstract class BcoPenaltiesState {
  const BcoPenaltiesState();
}

class BcoPenaltiesInitial extends BcoPenaltiesState {}

class BcoPenaltiesLoading extends BcoPenaltiesState {}

class BcoPenaltiesLoaded extends BcoPenaltiesState {
  final List<ExpressPenaltyModel> penalties;
  final bool hasReachedMax;
  final int currentPage;
  final String? currentFilter;

  const BcoPenaltiesLoaded({
    required this.penalties,
    required this.hasReachedMax,
    required this.currentPage,
    this.currentFilter,
  });

  BcoPenaltiesLoaded copyWith({
    List<ExpressPenaltyModel>? penalties,
    bool? hasReachedMax,
    int? currentPage,
    String? currentFilter,
  }) {
    return BcoPenaltiesLoaded(
      penalties: penalties ?? this.penalties,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class BcoPenaltiesError extends BcoPenaltiesState {
  final String message;

  const BcoPenaltiesError(this.message);
}
