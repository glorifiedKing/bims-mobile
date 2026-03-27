abstract class ClientProfileEvent {}

class FetchClientProfile extends ClientProfileEvent {}

class UpdateClientProfile extends ClientProfileEvent {
  final Map<String, dynamic> data;
  final bool requiresLogout;

  UpdateClientProfile(this.data, {this.requiresLogout = false});
}
