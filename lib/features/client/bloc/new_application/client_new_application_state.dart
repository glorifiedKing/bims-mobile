import 'package:equatable/equatable.dart';

abstract class ClientNewApplicationState extends Equatable {
  const ClientNewApplicationState();

  @override
  List<Object?> get props => [];
}

class ClientNewApplicationInitial extends ClientNewApplicationState {}

class ClientNewApplicationLoading extends ClientNewApplicationState {}

class ClientNewApplicationSuccess extends ClientNewApplicationState {}

class ClientNewApplicationError extends ClientNewApplicationState {
  final String message;

  const ClientNewApplicationError(this.message);

  @override
  List<Object?> get props => [message];
}
