import '../../../client/models/invoice_model.dart';

abstract class BcoGeneralInvoicesState {}

class BcoGeneralInvoicesInitial extends BcoGeneralInvoicesState {}

class BcoGeneralInvoicesLoading extends BcoGeneralInvoicesState {}

class BcoGeneralInvoicesLoaded extends BcoGeneralInvoicesState {
  final List<InvoiceModel> invoices;
  final bool hasReachedMax;
  final int currentPage;
  final String selectedFilter;

  BcoGeneralInvoicesLoaded({
    required this.invoices,
    required this.hasReachedMax,
    this.currentPage = 1,
    this.selectedFilter = 'ALL',
  });

  BcoGeneralInvoicesLoaded copyWith({
    List<InvoiceModel>? invoices,
    bool? hasReachedMax,
    int? currentPage,
    String? selectedFilter,
  }) {
    return BcoGeneralInvoicesLoaded(
      invoices: invoices ?? this.invoices,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class BcoGeneralInvoicesError extends BcoGeneralInvoicesState {
  final String message;
  BcoGeneralInvoicesError(this.message);
}
