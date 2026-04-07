abstract class BcoPenaltiesEvent {
  const BcoPenaltiesEvent();
}

class FetchBcoPenalties extends BcoPenaltiesEvent {
  final String? status;
  final bool isRefresh;

  const FetchBcoPenalties({this.status, this.isRefresh = false});
}

class LoadMoreBcoPenalties extends BcoPenaltiesEvent {}
