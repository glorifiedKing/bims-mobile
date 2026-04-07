import 'package:flutter_bloc/flutter_bloc.dart';
import 'bco_penalty_details_event.dart';
import 'bco_penalty_details_state.dart';
import '../../repositories/bco_repository.dart';

class BcoPenaltyDetailsBloc extends Bloc<BcoPenaltyDetailsEvent, BcoPenaltyDetailsState> {
  final BcoRepository repository;

  BcoPenaltyDetailsBloc({required this.repository}) : super(BcoPenaltyDetailsInitial()) {
    on<FetchBcoPenaltyDetails>(_onFetchBcoPenaltyDetails);
  }

  Future<void> _onFetchBcoPenaltyDetails(
    FetchBcoPenaltyDetails event,
    Emitter<BcoPenaltyDetailsState> emit,
  ) async {
    try {
      emit(BcoPenaltyDetailsLoading());
      final penalty = await repository.getExpressPenaltyDetails(event.reference);
      emit(BcoPenaltyDetailsLoaded(penalty));
    } catch (e) {
      emit(BcoPenaltyDetailsError(e.toString()));
    }
  }
}
