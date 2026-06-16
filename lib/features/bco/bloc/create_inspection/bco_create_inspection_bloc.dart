import 'package:flutter_bloc/flutter_bloc.dart';
import 'bco_create_inspection_event.dart';
import 'bco_create_inspection_state.dart';
import '../../repositories/bco_repository.dart';
import 'package:flutter/foundation.dart';

class BcoCreateInspectionBloc
    extends Bloc<BcoCreateInspectionEvent, BcoCreateInspectionState> {
  final BcoRepository repository;

  BcoCreateInspectionBloc({required this.repository})
    : super(BcoCreateInspectionInitial()) {
    on<SubmitCreateInspection>(_onSubmit);
    on<ResetCreateInspection>(_onReset);
  }

  Future<void> _onSubmit(
    SubmitCreateInspection event,
    Emitter<BcoCreateInspectionState> emit,
  ) async {
    emit(BcoCreateInspectionLoading());
    try {
      await repository.createInspection({
        'inspection_type': event.inspectionTypeId,
        'application_key': event.applicationKey,
        'start': event.start,
        'end': event.end,
        'pre_inspection_instructions': event.preInspectionInstructions,
      });
      emit(BcoCreateInspectionSuccess());
    } catch (e) {
      debugPrint(e.toString());
      emit(BcoCreateInspectionError(e.toString()));
    }
  }

  Future<void> _onReset(
    ResetCreateInspection event,
    Emitter<BcoCreateInspectionState> emit,
  ) async {
    emit(BcoCreateInspectionInitial());
  }
}
