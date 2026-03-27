abstract class BcoInspectionInvoiceDetailsEvent {}

class FetchBcoInspectionInvoiceDetails extends BcoInspectionInvoiceDetailsEvent {
  final String prn;
  FetchBcoInspectionInvoiceDetails(this.prn);
}
