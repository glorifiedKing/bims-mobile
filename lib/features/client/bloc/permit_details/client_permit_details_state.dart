import '../../models/permit_detail_model.dart';

abstract class ClientPermitDetailsState {}

class ClientPermitDetailsInitial extends ClientPermitDetailsState {}

class ClientPermitDetailsLoading extends ClientPermitDetailsState {}

class ClientPermitDetailsLoaded extends ClientPermitDetailsState {
  final PermitDetailModel permit;

  ClientPermitDetailsLoaded(this.permit);
}

class ClientPermitDetailsError extends ClientPermitDetailsState {
  final String message;

  ClientPermitDetailsError(this.message);
}
