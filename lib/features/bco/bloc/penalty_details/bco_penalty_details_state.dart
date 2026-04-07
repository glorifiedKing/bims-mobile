import '../../models/express_penalty_model.dart';

abstract class BcoPenaltyDetailsState {
  const BcoPenaltyDetailsState();
}

class BcoPenaltyDetailsInitial extends BcoPenaltyDetailsState {}

class BcoPenaltyDetailsLoading extends BcoPenaltyDetailsState {}

class BcoPenaltyDetailsLoaded extends BcoPenaltyDetailsState {
  final ExpressPenaltyModel penalty;

  const BcoPenaltyDetailsLoaded(this.penalty);
}

class BcoPenaltyDetailsError extends BcoPenaltyDetailsState {
  final String message;

  const BcoPenaltyDetailsError(this.message);
}
