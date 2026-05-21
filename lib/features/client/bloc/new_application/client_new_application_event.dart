import 'package:equatable/equatable.dart';

abstract class ClientNewApplicationEvent extends Equatable {
  const ClientNewApplicationEvent();

  @override
  List<Object?> get props => [];
}

class SubmitApplication extends ClientNewApplicationEvent {
  final Map<String, dynamic> data;

  const SubmitApplication(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateApplication extends ClientNewApplicationEvent {
  final String id;
  final Map<String, dynamic> data;

  const UpdateApplication(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}
