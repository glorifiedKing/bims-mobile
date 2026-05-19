import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_whistleblow_details_event.dart';
import 'bco_whistleblow_details_state.dart';

class BcoWhistleblowDetailsBloc extends Bloc<BcoWhistleblowDetailsEvent, BcoWhistleblowDetailsState> {
  final BcoRepository repository;

  BcoWhistleblowDetailsBloc({required this.repository}) : super(BcoWhistleblowDetailsInitial()) {
    on<FetchBcoWhistleblowDetails>(_onFetchBcoWhistleblowDetails);
  }

  Future<void> _onFetchBcoWhistleblowDetails(
    FetchBcoWhistleblowDetails event,
    Emitter<BcoWhistleblowDetailsState> emit,
  ) async {
    emit(BcoWhistleblowDetailsLoading());
    try {
      final details = await repository.getWhistleblowDetails(event.reference);
      emit(BcoWhistleblowDetailsLoaded(details));
    } catch (e) {
      emit(BcoWhistleblowDetailsError(e.toString()));
    }
  }
}
