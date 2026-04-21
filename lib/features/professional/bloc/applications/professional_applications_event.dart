abstract class ProfessionalApplicationsEvent {}

class FetchProfessionalApplications extends ProfessionalApplicationsEvent {
  final String status;

  FetchProfessionalApplications({this.status = 'ALL'});
}

class LoadMoreProfessionalApplications extends ProfessionalApplicationsEvent {}
