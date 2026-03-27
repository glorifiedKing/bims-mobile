import '../../../client/models/invoice_detail_model.dart';

abstract class BcoInvoiceDetailsState {}

class BcoInvoiceDetailsInitial extends BcoInvoiceDetailsState {}

class BcoInvoiceDetailsLoading extends BcoInvoiceDetailsState {}

class BcoInvoiceDetailsLoaded extends BcoInvoiceDetailsState {
  final InvoiceDetailModel details;

  BcoInvoiceDetailsLoaded(this.details);
}

class BcoInvoiceDetailsError extends BcoInvoiceDetailsState {
  final String message;

  BcoInvoiceDetailsError(this.message);
}
