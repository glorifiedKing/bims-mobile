abstract class ClientApplicationsEvent {}

class FetchClientApplications extends ClientApplicationsEvent {}

class LoadMoreClientApplications extends ClientApplicationsEvent {}

class ChangeClientApplicationsFilter extends ClientApplicationsEvent {
  final String filter;
  ChangeClientApplicationsFilter(this.filter);
}

class DeleteClientApplication extends ClientApplicationsEvent {
  final String applicationKey;
  DeleteClientApplication(this.applicationKey);
}
