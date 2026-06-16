abstract class BcoCreateInspectionEvent {
  const BcoCreateInspectionEvent();
}

class SubmitCreateInspection extends BcoCreateInspectionEvent {
  final int inspectionTypeId;
  final String applicationKey;
  final String start;
  final String end;
  final String preInspectionInstructions;

  const SubmitCreateInspection({
    required this.inspectionTypeId,
    required this.applicationKey,
    required this.start,
    required this.end,
    required this.preInspectionInstructions,
  });
}

class ResetCreateInspection extends BcoCreateInspectionEvent {}
