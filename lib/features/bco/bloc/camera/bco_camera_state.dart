import 'dart:typed_data';

abstract class BcoCameraState {
  const BcoCameraState();
}

class BcoCameraInitial extends BcoCameraState {}

class BcoCameraImageReady extends BcoCameraState {
  final Uint8List imageBytes;
  const BcoCameraImageReady(this.imageBytes);
}

class BcoCameraAnalyzing extends BcoCameraState {
  final Uint8List imageBytes;
  const BcoCameraAnalyzing(this.imageBytes);
}

class BcoCameraSuccess extends BcoCameraState {
  final Uint8List imageBytes;
  final String resultText;
  const BcoCameraSuccess({required this.imageBytes, required this.resultText});
}

class BcoCameraError extends BcoCameraState {
  final Uint8List? imageBytes;
  final String message;
  const BcoCameraError({this.imageBytes, required this.message});
}
