abstract class BcoCreatePenaltyState {
  const BcoCreatePenaltyState();
}

class BcoCreatePenaltyInitial extends BcoCreatePenaltyState {}

class BcoCreatePenaltyLoading extends BcoCreatePenaltyState {}

class BcoCreatePenaltySuccess extends BcoCreatePenaltyState {}

class BcoCreatePenaltyError extends BcoCreatePenaltyState {
  final String message;

  const BcoCreatePenaltyError(this.message);
}
