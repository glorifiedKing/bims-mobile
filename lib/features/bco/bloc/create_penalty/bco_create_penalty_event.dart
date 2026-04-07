abstract class BcoCreatePenaltyEvent {
  const BcoCreatePenaltyEvent();
}

class SubmitBcoCreatePenalty extends BcoCreatePenaltyEvent {
  final Map<String, dynamic> data;

  const SubmitBcoCreatePenalty(this.data);
}
