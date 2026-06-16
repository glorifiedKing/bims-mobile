abstract class BcoCreateInspectionState {
  const BcoCreateInspectionState();
}

class BcoCreateInspectionInitial extends BcoCreateInspectionState {}

class BcoCreateInspectionLoading extends BcoCreateInspectionState {}

class BcoCreateInspectionSuccess extends BcoCreateInspectionState {}

class BcoCreateInspectionError extends BcoCreateInspectionState {
  final String message;
  const BcoCreateInspectionError(this.message);
}
