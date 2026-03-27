abstract class BcoApplicationDetailsEvent {}

class FetchBcoApplicationDetails extends BcoApplicationDetailsEvent {
  final String applicationKey;
  FetchBcoApplicationDetails(this.applicationKey);
}

class LoadMoreBcoAuditTrail extends BcoApplicationDetailsEvent {
  final String applicationKey;
  LoadMoreBcoAuditTrail(this.applicationKey);
}

class ReviewBcoApplication extends BcoApplicationDetailsEvent {
  final String applicationKey;
  final String status;
  final String comment;

  ReviewBcoApplication({required this.applicationKey, required this.status, required this.comment});
}
