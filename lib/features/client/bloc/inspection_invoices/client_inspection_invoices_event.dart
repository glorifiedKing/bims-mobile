abstract class ClientInspectionInvoicesEvent {}

class FetchClientInspectionInvoices extends ClientInspectionInvoicesEvent {}

class LoadMoreClientInspectionInvoices extends ClientInspectionInvoicesEvent {}

class ChangeClientInspectionInvoicesFilter extends ClientInspectionInvoicesEvent {
  final String filter;
  ChangeClientInspectionInvoicesFilter(this.filter);
}

class SearchClientInspectionInvoices extends ClientInspectionInvoicesEvent {
  final String query;

  SearchClientInspectionInvoices(this.query);
}
