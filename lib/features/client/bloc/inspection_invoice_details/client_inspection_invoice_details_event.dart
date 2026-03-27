abstract class ClientInspectionInvoiceDetailsEvent {}

class FetchClientInspectionInvoiceDetails extends ClientInspectionInvoiceDetailsEvent {
  final String prn;
  FetchClientInspectionInvoiceDetails(this.prn);
}
