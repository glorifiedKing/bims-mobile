abstract class BcoInspectionInvoicesListEvent {}

class FetchBcoInspectionInvoicesList extends BcoInspectionInvoicesListEvent {
  final String? filter;
  final bool isRefresh;
  FetchBcoInspectionInvoicesList({this.filter, this.isRefresh = false});
}

class LoadMoreBcoInspectionInvoicesList extends BcoInspectionInvoicesListEvent {}

class ChangeBcoInspectionInvoicesListFilter extends BcoInspectionInvoicesListEvent {
  final String filter;
  ChangeBcoInspectionInvoicesListFilter(this.filter);
}
