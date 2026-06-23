import 'package:equatable/equatable.dart';

abstract class ClientAssessmentEvent extends Equatable {
  const ClientAssessmentEvent();

  @override
  List<Object?> get props => [];
}

class FetchAssessment extends ClientAssessmentEvent {
  final String applicationKey;

  const FetchAssessment(this.applicationKey);

  @override
  List<Object?> get props => [applicationKey];
}

class GeneratePrn extends ClientAssessmentEvent {
  final String applicationKey;
  final Map<String, dynamic> data;

  const GeneratePrn({
    required this.applicationKey,
    required this.data,
  });

  @override
  List<Object?> get props => [applicationKey, data];
}
