abstract class ClientInvoiceDetailsEvent {}

class FetchClientInvoiceDetails extends ClientInvoiceDetailsEvent {
  final String prn;

  FetchClientInvoiceDetails(this.prn);
}
