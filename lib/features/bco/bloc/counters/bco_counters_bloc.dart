import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_counters_event.dart';
import 'bco_counters_state.dart';

class BcoCountersBloc extends Bloc<BcoCountersEvent, BcoCountersState> {
  final BcoRepository repository;

  BcoCountersBloc({required this.repository}) : super(BcoCountersInitial()) {
    on<FetchBcoCounters>(_onFetchBcoCounters);
  }

  Future<void> _onFetchBcoCounters(
    FetchBcoCounters event,
    Emitter<BcoCountersState> emit,
  ) async {
    emit(BcoCountersLoading());
    try {
      final counters = await repository.getCounters();
      emit(BcoCountersLoaded(counters));
    } catch (e) {
      emit(BcoCountersError(e.toString()));
    }
  }
}
