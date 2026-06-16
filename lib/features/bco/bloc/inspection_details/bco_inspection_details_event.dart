abstract class BcoInspectionDetailsEvent {
  const BcoInspectionDetailsEvent();
}

class FetchBcoInspectionDetails extends BcoInspectionDetailsEvent {
  final String reference;
  const FetchBcoInspectionDetails(this.reference);
}

class UpdateBcoInspection extends BcoInspectionDetailsEvent {
  final String reference;
  final int statusId;
  final String applicationKey;
  final String? start;
  final String? end;
  final String? postInspectionComments;

  const UpdateBcoInspection({
    required this.reference,
    required this.statusId,
    required this.applicationKey,
    this.start,
    this.end,
    this.postInspectionComments,
  });
}
