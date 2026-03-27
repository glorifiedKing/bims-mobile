import '../../models/inspection_invoice_model.dart';

abstract class ClientInspectionInvoiceDetailsState {}

class ClientInspectionInvoiceDetailsInitial extends ClientInspectionInvoiceDetailsState {}

class ClientInspectionInvoiceDetailsLoading extends ClientInspectionInvoiceDetailsState {}

class ClientInspectionInvoiceDetailsLoaded extends ClientInspectionInvoiceDetailsState {
  final InspectionInvoiceModel invoice;
  ClientInspectionInvoiceDetailsLoaded(this.invoice);
}

class ClientInspectionInvoiceDetailsError extends ClientInspectionInvoiceDetailsState {
  final String message;
  ClientInspectionInvoiceDetailsError(this.message);
}
