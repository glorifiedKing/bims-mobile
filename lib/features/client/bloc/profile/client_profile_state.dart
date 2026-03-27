import '../../models/client_profile_model.dart';

abstract class ClientProfileState {}

class ClientProfileInitial extends ClientProfileState {}

class ClientProfileLoading extends ClientProfileState {}

class ClientProfileLoaded extends ClientProfileState {
  final ClientProfileModel profile;

  ClientProfileLoaded(this.profile);
}

class ClientProfileError extends ClientProfileState {
  final String message;

  ClientProfileError(this.message);
}

class ClientProfileUpdateLoading extends ClientProfileState {}

class ClientProfileUpdateSuccess extends ClientProfileState {
  final bool requiresLogout;

  ClientProfileUpdateSuccess({required this.requiresLogout});
}

class ClientProfileUpdateFailure extends ClientProfileState {
  final String message;

  ClientProfileUpdateFailure(this.message);
}
