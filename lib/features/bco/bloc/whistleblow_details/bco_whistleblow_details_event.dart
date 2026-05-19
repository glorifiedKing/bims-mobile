import 'package:equatable/equatable.dart';

abstract class BcoWhistleblowDetailsEvent extends Equatable {
  const BcoWhistleblowDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchBcoWhistleblowDetails extends BcoWhistleblowDetailsEvent {
  final String reference;

  const FetchBcoWhistleblowDetails(this.reference);

  @override
  List<Object?> get props => [reference];
}
