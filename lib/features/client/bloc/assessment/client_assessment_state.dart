import 'package:equatable/equatable.dart';
import '../../models/assessment_model.dart';

abstract class ClientAssessmentState extends Equatable {
  const ClientAssessmentState();

  @override
  List<Object?> get props => [];
}

class ClientAssessmentInitial extends ClientAssessmentState {}

class ClientAssessmentLoading extends ClientAssessmentState {}

class ClientAssessmentLoaded extends ClientAssessmentState {
  final AssessmentModel assessmentModel;

  const ClientAssessmentLoaded(this.assessmentModel);

  @override
  List<Object?> get props => [assessmentModel];
}

class ClientAssessmentError extends ClientAssessmentState {
  final String message;

  const ClientAssessmentError(this.message);

  @override
  List<Object?> get props => [message];
}

class ClientAssessmentPrnGenerated extends ClientAssessmentState {
  final String prn;

  const ClientAssessmentPrnGenerated(this.prn);

  @override
  List<Object?> get props => [prn];
}
