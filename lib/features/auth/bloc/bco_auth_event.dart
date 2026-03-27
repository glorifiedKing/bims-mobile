abstract class BcoAuthEvent {}

class BcoAuthLoginRequested extends BcoAuthEvent {
  final String email;
  final String password;

  BcoAuthLoginRequested({required this.email, required this.password});
}

class BcoAuthLogoutRequested extends BcoAuthEvent {}

class BcoAuthCheckRequested extends BcoAuthEvent {}
