abstract class BcoPenaltyDetailsEvent {
  const BcoPenaltyDetailsEvent();
}

class FetchBcoPenaltyDetails extends BcoPenaltyDetailsEvent {
  final String reference;

  const FetchBcoPenaltyDetails(this.reference);
}
