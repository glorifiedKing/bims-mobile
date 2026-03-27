import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_profile_event.dart';
import 'bco_profile_state.dart';

class BcoProfileBloc extends Bloc<BcoProfileEvent, BcoProfileState> {
  final BcoRepository repository;

  BcoProfileBloc({required this.repository}) : super(BcoProfileInitial()) {
    on<FetchBcoProfile>(_onFetchBcoProfile);
  }

  Future<void> _onFetchBcoProfile(
    FetchBcoProfile event,
    Emitter<BcoProfileState> emit,
  ) async {
    emit(BcoProfileLoading());
    try {
      final profile = await repository.getProfileDetails();
      emit(BcoProfileLoaded(profile));
    } catch (e) {
      emit(BcoProfileError(e.toString()));
    }
  }
}
