import '../../models/bco_counters_model.dart';

abstract class BcoCountersState {}

class BcoCountersInitial extends BcoCountersState {}

class BcoCountersLoading extends BcoCountersState {}

class BcoCountersLoaded extends BcoCountersState {
  final BcoCountersModel counters;

  BcoCountersLoaded(this.counters);
}

class BcoCountersError extends BcoCountersState {
  final String message;

  BcoCountersError(this.message);
}
