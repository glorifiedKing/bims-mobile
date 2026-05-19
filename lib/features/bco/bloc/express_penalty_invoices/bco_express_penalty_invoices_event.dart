abstract class BcoExpressPenaltyInvoicesEvent {}

class FetchBcoExpressPenaltyInvoices extends BcoExpressPenaltyInvoicesEvent {
  final bool isRefresh;
  FetchBcoExpressPenaltyInvoices({this.isRefresh = false});
}

class LoadMoreBcoExpressPenaltyInvoices extends BcoExpressPenaltyInvoicesEvent {}

class ChangeBcoExpressPenaltyInvoicesFilter extends BcoExpressPenaltyInvoicesEvent {
  final String filter;
  ChangeBcoExpressPenaltyInvoicesFilter(this.filter);
}
