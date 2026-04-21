import '../../models/professional_counters.dart';

abstract class ProfessionalCountersState {}

class ProfessionalCountersInitial extends ProfessionalCountersState {}

class ProfessionalCountersLoading extends ProfessionalCountersState {}

class ProfessionalCountersLoaded extends ProfessionalCountersState {
  final ProfessionalCounters counters;

  ProfessionalCountersLoaded(this.counters);
}

class ProfessionalCountersError extends ProfessionalCountersState {
  final String message;

  ProfessionalCountersError(this.message);
}
