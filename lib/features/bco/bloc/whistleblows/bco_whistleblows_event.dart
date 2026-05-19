import 'package:equatable/equatable.dart';

abstract class BcoWhistleblowsEvent extends Equatable {
  const BcoWhistleblowsEvent();

  @override
  List<Object?> get props => [];
}

class FetchBcoWhistleblows extends BcoWhistleblowsEvent {
  final bool isRefresh;
  final String? feedbackType;
  final String? adminUnitId;
  final String? search;

  const FetchBcoWhistleblows({
    this.isRefresh = false,
    this.feedbackType,
    this.adminUnitId,
    this.search,
  });

  @override
  List<Object?> get props => [isRefresh, feedbackType, adminUnitId, search];
}

class LoadMoreBcoWhistleblows extends BcoWhistleblowsEvent {}
