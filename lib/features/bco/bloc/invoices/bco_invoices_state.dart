abstract class BcoInvoicesState {}

class BcoInvoicesInitial extends BcoInvoicesState {}

class BcoInvoicesLoading extends BcoInvoicesState {}

class BcoInvoicesLoaded extends BcoInvoicesState {
  final String generalTotal;
  final String inspectionTotal;

  BcoInvoicesLoaded({required this.generalTotal, required this.inspectionTotal});
}

class BcoInvoicesError extends BcoInvoicesState {
  final String message;

  BcoInvoicesError(this.message);
}
