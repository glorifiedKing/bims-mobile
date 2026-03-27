abstract class BcoInvoiceDetailsEvent {}

class FetchBcoInvoiceDetails extends BcoInvoiceDetailsEvent {
  final String prn;
  FetchBcoInvoiceDetails(this.prn);
}
