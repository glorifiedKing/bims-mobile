abstract class ClientInvoicesEvent {}

class FetchClientInvoices extends ClientInvoicesEvent {}

class LoadMoreClientInvoices extends ClientInvoicesEvent {}

class ChangeClientInvoicesFilter extends ClientInvoicesEvent {
  final String filter;
  ChangeClientInvoicesFilter(this.filter);
}

class SearchClientInvoices extends ClientInvoicesEvent {
  final String query;

  SearchClientInvoices(this.query);
}
