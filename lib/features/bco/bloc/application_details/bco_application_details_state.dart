import '../../../client/models/application_detail_model.dart';
import '../../models/audit_trail_model.dart';

abstract class BcoApplicationDetailsState {}

class BcoApplicationDetailsInitial extends BcoApplicationDetailsState {}

class BcoApplicationDetailsLoading extends BcoApplicationDetailsState {}

class BcoApplicationDetailsLoaded extends BcoApplicationDetailsState {
  final ApplicationDetailModel details;
  final List<AuditTrailModel> auditTrail;
  final bool hasReachedMaxAudit;
  final int currentAuditPage;
  final bool isReviewing;
  final String? reviewError;
  final bool reviewSuccess;

  BcoApplicationDetailsLoaded({
    required this.details,
    required this.auditTrail,
    this.hasReachedMaxAudit = true,
    this.currentAuditPage = 1,
    this.isReviewing = false,
    this.reviewError,
    this.reviewSuccess = false,
  });

  BcoApplicationDetailsLoaded copyWith({
    ApplicationDetailModel? details,
    List<AuditTrailModel>? auditTrail,
    bool? hasReachedMaxAudit,
    int? currentAuditPage,
    bool? isReviewing,
    String? reviewError,
    bool? reviewSuccess,
  }) {
    return BcoApplicationDetailsLoaded(
      details: details ?? this.details,
      auditTrail: auditTrail ?? this.auditTrail,
      hasReachedMaxAudit: hasReachedMaxAudit ?? this.hasReachedMaxAudit,
      currentAuditPage: currentAuditPage ?? this.currentAuditPage,
      isReviewing: isReviewing ?? this.isReviewing,
      reviewError: reviewError,
      reviewSuccess: reviewSuccess ?? this.reviewSuccess,
    );
  }
}

class BcoApplicationDetailsError extends BcoApplicationDetailsState {
  final String message;
  BcoApplicationDetailsError(this.message);
}
