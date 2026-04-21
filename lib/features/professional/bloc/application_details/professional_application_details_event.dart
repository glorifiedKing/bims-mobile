abstract class ProfessionalApplicationDetailsEvent {}

class FetchProfessionalApplicationDetails extends ProfessionalApplicationDetailsEvent {
  final String applicationKey;

  FetchProfessionalApplicationDetails(this.applicationKey);
}
