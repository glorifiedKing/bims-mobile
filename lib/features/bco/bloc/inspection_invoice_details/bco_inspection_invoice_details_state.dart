import '../../../client/models/inspection_invoice_model.dart';

abstract class BcoInspectionInvoiceDetailsState {}

class BcoInspectionInvoiceDetailsInitial extends BcoInspectionInvoiceDetailsState {}

class BcoInspectionInvoiceDetailsLoading extends BcoInspectionInvoiceDetailsState {}

class BcoInspectionInvoiceDetailsLoaded extends BcoInspectionInvoiceDetailsState {
  final InspectionInvoiceModel details;

  BcoInspectionInvoiceDetailsLoaded(this.details);
}

class BcoInspectionInvoiceDetailsError extends BcoInspectionInvoiceDetailsState {
  final String message;

  BcoInspectionInvoiceDetailsError(this.message);
}
