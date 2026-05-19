import 'package:equatable/equatable.dart';
import '../../models/bco_whistleblow_model.dart';

abstract class BcoWhistleblowDetailsState extends Equatable {
  const BcoWhistleblowDetailsState();

  @override
  List<Object?> get props => [];
}

class BcoWhistleblowDetailsInitial extends BcoWhistleblowDetailsState {}

class BcoWhistleblowDetailsLoading extends BcoWhistleblowDetailsState {}

class BcoWhistleblowDetailsLoaded extends BcoWhistleblowDetailsState {
  final BcoWhistleblowModel whistleblow;

  const BcoWhistleblowDetailsLoaded(this.whistleblow);

  @override
  List<Object?> get props => [whistleblow];
}

class BcoWhistleblowDetailsError extends BcoWhistleblowDetailsState {
  final String message;

  const BcoWhistleblowDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
