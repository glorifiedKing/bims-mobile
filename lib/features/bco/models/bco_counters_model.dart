class BcoCountersModel {
  final int totalNewApplications;
  final int totalPendingSubmissions;
  final int totalApprovedApplications;
  final int totalDeferred;

  BcoCountersModel({
    required this.totalNewApplications,
    required this.totalPendingSubmissions,
    required this.totalApprovedApplications,
    required this.totalDeferred,
  });

  factory BcoCountersModel.fromJson(Map<String, dynamic> json) {
    return BcoCountersModel(
      totalNewApplications: json['totalNewApplications'] ?? 0,
      totalPendingSubmissions: json['totalPendingSubmissions'] ?? 0,
      totalApprovedApplications: json['totalApprovedApplications'] ?? 0,
      totalDeferred: json['totalDeferred'] ?? 0,
    );
  }
}
