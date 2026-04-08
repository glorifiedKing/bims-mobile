import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../bloc/camera/bco_camera_bloc.dart';
import '../bloc/camera/bco_camera_event.dart';
import '../bloc/camera/bco_camera_state.dart';

class BcoCameraScreen extends StatefulWidget {
  const BcoCameraScreen({super.key});

  @override
  State<BcoCameraScreen> createState() => _BcoCameraScreenState();
}

class _BcoCameraScreenState extends State<BcoCameraScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source, imageQuality: 80);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          context.read<BcoCameraBloc>().add(BcoCameraImagePicked(bytes));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.primaryGreen),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.primaryGreen),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F0),
      appBar: AppBar(
        title: const Text(
          'AI Camera Analysis',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BcoCameraBloc>().add(BcoCameraReset());
            },
          )
        ],
      ),
      body: BlocConsumer<BcoCameraBloc, BcoCameraState>(
        listener: (context, state) {
          if (state is BcoCameraError) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          Uint8List? currentImage;
          bool isAnalyzing = false;
          String? result;

          if (state is BcoCameraImageReady) currentImage = state.imageBytes;
          if (state is BcoCameraAnalyzing) { currentImage = state.imageBytes; isAnalyzing = true; }
          if (state is BcoCameraSuccess) { currentImage = state.imageBytes; result = state.resultText; }
          if (state is BcoCameraError) currentImage = state.imageBytes;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Display
                      if (currentImage == null)
                        GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 255 * 0.3), width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_a_photo, size: 60, color: AppTheme.primaryGreen),
                                SizedBox(height: 15),
                                Text(
                                  'Tap to capture or select image',
                                  style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            currentImage,
                            fit: BoxFit.cover,
                            height: 300,
                            width: double.infinity,
                          ),
                        ),
                        
                      const SizedBox(height: 20),

                      // Results
                      if (isAnalyzing) ...[
                        const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
                        const SizedBox(height: 15),
                        const Center(child: Text('AI is analyzing the scene for safety violations and measurements...')),
                      ] else if (result != null) ...[
                        const Text(
                          'AI Analysis Result',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 255 * 0.05), blurRadius: 10, offset: const Offset(0, 5)),
                            ]
                          ),
                          child: SelectableText(
                            result,
                            style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Button Bar
              if (currentImage != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 255 * 0.05), blurRadius: 10, offset: const Offset(0, -5))
                    ]
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isAnalyzing ? null : _showImageSourceDialog,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            foregroundColor: AppTheme.primaryGreen,
                            side: const BorderSide(color: AppTheme.primaryGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('RETAKE'),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: (isAnalyzing || result != null) 
                            ? null 
                            : () => context.read<BcoCameraBloc>().add(BcoCameraAnalyzeImage(currentImage!)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('ANALYZE IMAGE', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
