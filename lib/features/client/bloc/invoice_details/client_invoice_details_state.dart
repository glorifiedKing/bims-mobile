import '../../models/invoice_detail_model.dart';

abstract class ClientInvoiceDetailsState {}

class ClientInvoiceDetailsInitial extends ClientInvoiceDetailsState {}

class ClientInvoiceDetailsLoading extends ClientInvoiceDetailsState {}

class ClientInvoiceDetailsLoaded extends ClientInvoiceDetailsState {
  final InvoiceDetailModel invoice;

  ClientInvoiceDetailsLoaded(this.invoice);
}

class ClientInvoiceDetailsError extends ClientInvoiceDetailsState {
  final String message;

  ClientInvoiceDetailsError(this.message);
}
