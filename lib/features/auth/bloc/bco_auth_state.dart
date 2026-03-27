import '../models/bco_user.dart';

abstract class BcoAuthState {}

class BcoAuthInitial extends BcoAuthState {}

class BcoAuthLoading extends BcoAuthState {}

class BcoAuthAuthenticated extends BcoAuthState {
  final String token;
  final BcoUser user;

  BcoAuthAuthenticated(this.token, this.user);
}

class BcoAuthUnauthenticated extends BcoAuthState {}

class BcoAuthError extends BcoAuthState {
  final String message;

  BcoAuthError(this.message);
}
