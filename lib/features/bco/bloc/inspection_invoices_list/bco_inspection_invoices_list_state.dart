import '../../../client/models/inspection_invoice_model.dart';

abstract class BcoInspectionInvoicesListState {}

class BcoInspectionInvoicesListInitial extends BcoInspectionInvoicesListState {}

class BcoInspectionInvoicesListLoading extends BcoInspectionInvoicesListState {}

class BcoInspectionInvoicesListLoaded extends BcoInspectionInvoicesListState {
  final List<InspectionInvoiceModel> invoices;
  final bool hasReachedMax;
  final int currentPage;
  final String selectedFilter;

  BcoInspectionInvoicesListLoaded({
    required this.invoices,
    required this.hasReachedMax,
    this.currentPage = 1,
    this.selectedFilter = 'ALL',
  });

  BcoInspectionInvoicesListLoaded copyWith({
    List<InspectionInvoiceModel>? invoices,
    bool? hasReachedMax,
    int? currentPage,
    String? selectedFilter,
  }) {
    return BcoInspectionInvoicesListLoaded(
      invoices: invoices ?? this.invoices,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class BcoInspectionInvoicesListError extends BcoInspectionInvoicesListState {
  final String message;
  BcoInspectionInvoicesListError(this.message);
}
