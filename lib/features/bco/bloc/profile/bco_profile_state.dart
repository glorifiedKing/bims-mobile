import '../../models/bco_profile_model.dart';

abstract class BcoProfileState {}

class BcoProfileInitial extends BcoProfileState {}

class BcoProfileLoading extends BcoProfileState {}

class BcoProfileLoaded extends BcoProfileState {
  final BcoProfileModel profile;

  BcoProfileLoaded(this.profile);
}

class BcoProfileError extends BcoProfileState {
  final String message;

  BcoProfileError(this.message);
}
