import 'package:equatable/equatable.dart';
import '../../models/bco_whistleblow_model.dart';

abstract class BcoWhistleblowsState extends Equatable {
  const BcoWhistleblowsState();

  @override
  List<Object?> get props => [];
}

class BcoWhistleblowsInitial extends BcoWhistleblowsState {}

class BcoWhistleblowsLoading extends BcoWhistleblowsState {}

class BcoWhistleblowsLoaded extends BcoWhistleblowsState {
  final List<BcoWhistleblowModel> whistleblows;
  final bool hasReachedMax;
  final int currentPage;

  const BcoWhistleblowsLoaded({
    required this.whistleblows,
    required this.hasReachedMax,
    required this.currentPage,
  });

  BcoWhistleblowsLoaded copyWith({
    List<BcoWhistleblowModel>? whistleblows,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return BcoWhistleblowsLoaded(
      whistleblows: whistleblows ?? this.whistleblows,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [whistleblows, hasReachedMax, currentPage];
}

class BcoWhistleblowsError extends BcoWhistleblowsState {
  final String message;

  const BcoWhistleblowsError(this.message);

  @override
  List<Object?> get props => [message];
}
