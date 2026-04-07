import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_create_penalty_event.dart';
import 'bco_create_penalty_state.dart';

class BcoCreatePenaltyBloc extends Bloc<BcoCreatePenaltyEvent, BcoCreatePenaltyState> {
  final BcoRepository repository;

  BcoCreatePenaltyBloc({required this.repository}) : super(BcoCreatePenaltyInitial()) {
    on<SubmitBcoCreatePenalty>(_onSubmitBcoCreatePenalty);
  }

  Future<void> _onSubmitBcoCreatePenalty(
    SubmitBcoCreatePenalty event,
    Emitter<BcoCreatePenaltyState> emit,
  ) async {
    try {
      emit(BcoCreatePenaltyLoading());
      await repository.createExpressPenalty(event.data);
      emit(BcoCreatePenaltySuccess());
    } catch (e) {
      emit(BcoCreatePenaltyError(e.toString()));
    }
  }
}
