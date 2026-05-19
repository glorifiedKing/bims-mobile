import '../../models/express_penalty_invoice_model.dart';

abstract class BcoExpressPenaltyInvoicesState {}

class BcoExpressPenaltyInvoicesInitial extends BcoExpressPenaltyInvoicesState {}

class BcoExpressPenaltyInvoicesLoading extends BcoExpressPenaltyInvoicesState {
  final List<ExpressPenaltyInvoiceModel> oldInvoices;
  final bool isFirstFetch;

  BcoExpressPenaltyInvoicesLoading(this.oldInvoices, {this.isFirstFetch = false});
}

class BcoExpressPenaltyInvoicesLoaded extends BcoExpressPenaltyInvoicesState {
  final List<ExpressPenaltyInvoiceModel> invoices;
  final bool hasReachedMax;
  final String selectedFilter;

  BcoExpressPenaltyInvoicesLoaded(
    this.invoices,
    this.hasReachedMax,
    this.selectedFilter,
  );
}

class BcoExpressPenaltyInvoicesError extends BcoExpressPenaltyInvoicesState {
  final String message;
  BcoExpressPenaltyInvoicesError(this.message);
}
