import 'dart:typed_data';

abstract class BcoCameraEvent {
  const BcoCameraEvent();
}

class BcoCameraImagePicked extends BcoCameraEvent {
  final Uint8List imageBytes;
  const BcoCameraImagePicked(this.imageBytes);
}

class BcoCameraAnalyzeImage extends BcoCameraEvent {
  final Uint8List imageBytes;
  const BcoCameraAnalyzeImage(this.imageBytes);
}

class BcoCameraReset extends BcoCameraEvent {}
