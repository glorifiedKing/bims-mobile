import '../../models/inspection_invoice_model.dart';

abstract class ClientInspectionInvoicesState {}

class ClientInspectionInvoicesInitial extends ClientInspectionInvoicesState {}

class ClientInspectionInvoicesLoading extends ClientInspectionInvoicesState {}

class ClientInspectionInvoicesLoaded extends ClientInspectionInvoicesState {
  final List<InspectionInvoiceModel> invoices;
  final bool hasReachedMax;
  final String selectedFilter;
  final int currentPage;
  final String? totalUnpaid;
  final String? searchQuery;

  ClientInspectionInvoicesLoaded({
    required this.invoices,
    required this.hasReachedMax,
    this.selectedFilter = 'ALL',
    this.currentPage = 1,
    this.totalUnpaid,
    this.searchQuery,
  });

  ClientInspectionInvoicesLoaded copyWith({
    List<InspectionInvoiceModel>? invoices,
    bool? hasReachedMax,
    String? selectedFilter,
    int? currentPage,
    String? totalUnpaid,
    String? searchQuery,
  }) {
    return ClientInspectionInvoicesLoaded(
      invoices: invoices ?? this.invoices,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      currentPage: currentPage ?? this.currentPage,
      totalUnpaid: totalUnpaid ?? this.totalUnpaid,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ClientInspectionInvoicesError extends ClientInspectionInvoicesState {
  final String message;
  ClientInspectionInvoicesError(this.message);
}
