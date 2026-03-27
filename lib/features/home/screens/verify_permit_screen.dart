import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme.dart';
import '../../../core/network/public_repository.dart';
import '../../../core/constants/api_constants.dart';

class VerifyPermitScreen extends StatefulWidget {
  const VerifyPermitScreen({super.key});

  @override
  State<VerifyPermitScreen> createState() => _VerifyPermitScreenState();
}

class _VerifyPermitScreenState extends State<VerifyPermitScreen> {
  final TextEditingController _serialController = TextEditingController();
  final PublicRepository _repository = PublicRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _verifyPermit(String serial) async {
    if (serial.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final permit = await _repository.verifyPermit(
        serial.trim(),
        ApiConstants
            .baseUrl, // Assuming trailing slash not needed as per path design
      );

      if (!mounted) return;

      // Push to the details screen, passing the preloaded permit
      context.push('/verify-permit/details', extra: permit);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String? code = barcodes.first.rawValue;
                    if (code != null) {
                      Navigator.pop(context); // Close scanner
                      _serialController.text = code;
                      _verifyPermit(code);
                    }
                  }
                },
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Text(
                  'Scan Permit QR Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Verify Permit'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 80,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 20),
              const Text(
                'Verify Permit',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter the 14-character permit serial number below, or scan the QR code located on the printed permit to verify its authenticity.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _serialController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Permit Serial Number',
                  hintText: 'e.g. NBRB-SQHGMAF36S',
                  prefixIcon: const Icon(Icons.tag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.accentGold,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: () => _verifyPermit(_serialController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('VERIFY', style: TextStyle(fontSize: 16)),
                ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _openScanner,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('SCAN QR CODE'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                    color: AppTheme.primaryGreen,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
