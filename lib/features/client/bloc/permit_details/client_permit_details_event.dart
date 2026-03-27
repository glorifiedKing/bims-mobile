abstract class ClientPermitDetailsEvent {}

class FetchClientPermitDetails extends ClientPermitDetailsEvent {
  final String serialNo;

  FetchClientPermitDetails(this.serialNo);
}
