abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String identifier;
  final String password;
  final String type;

  AuthLoginRequested({
    required this.identifier,
    required this.password,
    required this.type,
  });
}

class AuthRegisterRequested extends AuthEvent {
  final Map<String, dynamic> data;

  AuthRegisterRequested(this.data);
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
