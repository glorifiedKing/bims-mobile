import 'package:flutter_bloc/flutter_bloc.dart';
import 'bco_inspection_details_event.dart';
import 'bco_inspection_details_state.dart';
import '../../repositories/bco_repository.dart';

class BcoInspectionDetailsBloc
    extends Bloc<BcoInspectionDetailsEvent, BcoInspectionDetailsState> {
  final BcoRepository repository;

  BcoInspectionDetailsBloc({required this.repository})
      : super(BcoInspectionDetailsInitial()) {
    on<FetchBcoInspectionDetails>(_onFetch);
    on<UpdateBcoInspection>(_onUpdate);
  }

  Future<void> _onFetch(
    FetchBcoInspectionDetails event,
    Emitter<BcoInspectionDetailsState> emit,
  ) async {
    try {
      emit(BcoInspectionDetailsLoading());
      final inspection = await repository.getInspectionDetails(event.reference);
      emit(BcoInspectionDetailsLoaded(inspection: inspection));
    } catch (e) {
      emit(BcoInspectionDetailsError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateBcoInspection event,
    Emitter<BcoInspectionDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BcoInspectionDetailsLoaded) return;

    emit(currentState.copyWith(isUpdating: true));

    try {
      final data = <String, dynamic>{
        'status': event.statusId,
        'application_key': event.applicationKey,
      };
      if (event.start != null) data['start'] = event.start;
      if (event.end != null) data['end'] = event.end;
      if (event.postInspectionComments != null && event.postInspectionComments!.isNotEmpty) {
        data['post_inspection_comments'] = event.postInspectionComments;
      }

      await repository.updateInspection(event.reference, data);

      // Re-fetch updated details
      final updated = await repository.getInspectionDetails(event.reference);
      emit(BcoInspectionDetailsLoaded(
        inspection: updated,
        isUpdating: false,
        updateSuccess: true,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isUpdating: false,
        updateError: e.toString(),
      ));
    }
  }
}
