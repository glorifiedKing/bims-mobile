abstract class ClientApplicationDetailsEvent {}

class FetchClientApplicationDetails extends ClientApplicationDetailsEvent {
  final String applicationKey;

  FetchClientApplicationDetails(this.applicationKey);
}

class DownloadClientApplicationPdf extends ClientApplicationDetailsEvent {
  final String applicationKey;

  DownloadClientApplicationPdf(this.applicationKey);
}
