abstract class ClientPermitsEvent {}

class FetchClientPermits extends ClientPermitsEvent {}

class LoadMoreClientPermits extends ClientPermitsEvent {}

class SearchClientPermits extends ClientPermitsEvent {
  final String query;

  SearchClientPermits(this.query);
}
