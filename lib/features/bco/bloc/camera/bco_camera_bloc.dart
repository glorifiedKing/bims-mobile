import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bco_camera_event.dart';
import 'bco_camera_state.dart';

class BcoCameraBloc extends Bloc<BcoCameraEvent, BcoCameraState> {
  BcoCameraBloc() : super(BcoCameraInitial()) {
    on<BcoCameraImagePicked>(_onImagePicked);
    on<BcoCameraAnalyzeImage>(_onAnalyzeImage);
    on<BcoCameraReset>((event, emit) => emit(BcoCameraInitial()));
  }

  void _onImagePicked(
    BcoCameraImagePicked event,
    Emitter<BcoCameraState> emit,
  ) {
    emit(BcoCameraImageReady(event.imageBytes));
  }

  Future<void> _onAnalyzeImage(
    BcoCameraAnalyzeImage event,
    Emitter<BcoCameraState> emit,
  ) async {
    emit(BcoCameraAnalyzing(event.imageBytes));
    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-3.1-flash-lite-preview',
      );

      final prompt = TextPart(
        'You are an expert safety inspector analyzing construction sites and buildings for compliance. '
        'Identify any visible safety violations. '
        'If an emergency exit is present, estimate its visible width based on surrounding context. '
        'If a wheelchair ramp is visible, accurately estimate its slope ratio. '
        'Provide a detailed, structural analysis highlighting structural components, safety gear, '
        'compliance with accessible routes, and general observations. '
        'Do not mention that you cannot make precise measurements; just give your best visual estimate. '
        'Format clearly with bullet points.',
      );

      final imagePart = InlineDataPart('image/jpeg', event.imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      if (response.text != null && response.text!.isNotEmpty) {
        emit(
          BcoCameraSuccess(
            imageBytes: event.imageBytes,
            resultText: response.text!,
          ),
        );
      } else {
        emit(
          BcoCameraError(
            imageBytes: event.imageBytes,
            message: 'No analysis could be generated.',
          ),
        );
      }
    } catch (e) {
      emit(
        BcoCameraError(
          imageBytes: event.imageBytes,
          message: 'Analysis failed: $e',
        ),
      );
    }
  }
}
