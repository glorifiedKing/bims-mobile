abstract class BcoApplicationsEvent {}

class FetchBcoApplications extends BcoApplicationsEvent {
  final String? status;
  final bool isRefresh;
  FetchBcoApplications({this.status, this.isRefresh = false});
}

class LoadMoreBcoApplications extends BcoApplicationsEvent {}
