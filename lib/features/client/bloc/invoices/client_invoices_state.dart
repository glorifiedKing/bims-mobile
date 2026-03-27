import '../../models/invoice_model.dart';

abstract class ClientInvoicesState {}

class ClientInvoicesInitial extends ClientInvoicesState {}

class ClientInvoicesLoading extends ClientInvoicesState {}

class ClientInvoicesLoaded extends ClientInvoicesState {
  final List<InvoiceModel> invoices;
  final bool hasReachedMax;
  final String selectedFilter;
  final String? totalUnpaid;
  final String? searchQuery;

  ClientInvoicesLoaded({
    required this.invoices,
    this.hasReachedMax = false,
    this.selectedFilter = 'ALL',
    this.totalUnpaid,
    this.searchQuery,
  });

  ClientInvoicesLoaded copyWith({
    List<InvoiceModel>? invoices,
    bool? hasReachedMax,
    String? selectedFilter,
    String? totalUnpaid,
    String? searchQuery,
  }) {
    return ClientInvoicesLoaded(
      invoices: invoices ?? this.invoices,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      totalUnpaid: totalUnpaid ?? this.totalUnpaid,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ClientInvoicesError extends ClientInvoicesState {
  final String message;

  ClientInvoicesError(this.message);
}
