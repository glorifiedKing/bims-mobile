abstract class BcoGeneralInvoicesEvent {}

class FetchBcoGeneralInvoices extends BcoGeneralInvoicesEvent {
  final String? filter;
  final bool isRefresh;
  FetchBcoGeneralInvoices({this.filter, this.isRefresh = false});
}

class LoadMoreBcoGeneralInvoices extends BcoGeneralInvoicesEvent {}

class ChangeBcoGeneralInvoicesFilter extends BcoGeneralInvoicesEvent {
  final String filter;
  ChangeBcoGeneralInvoicesFilter(this.filter);
}
