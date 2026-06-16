abstract class BcoInspectionsEvent {
  const BcoInspectionsEvent();
}

class FetchBcoInspections extends BcoInspectionsEvent {
  final int? inspectionTypeId;
  final int? inspectionStatusId;
  final String? start;
  final String? end;
  final bool isRefresh;

  const FetchBcoInspections({
    this.inspectionTypeId,
    this.inspectionStatusId,
    this.start,
    this.end,
    this.isRefresh = false,
  });
}

class LoadMoreBcoInspections extends BcoInspectionsEvent {}
