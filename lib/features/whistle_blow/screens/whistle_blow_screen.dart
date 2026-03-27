import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class WhistleBlowScreen extends StatefulWidget {
  const WhistleBlowScreen({super.key});

  @override
  State<WhistleBlowScreen> createState() => _WhistleBlowScreenState();
}

class _WhistleBlowScreenState extends State<WhistleBlowScreen> {
  String? _selectedViolation;
  final _detailsController = TextEditingController();

  final List<String> _violations = [
    'No Building Permit Displayed',
    'Illegal Construction',
    'Lack of Safety Measures',
    'Construction During Night',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submitReport() {
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Submitted'),
        content: const Text(
          'Report Submitted Anonymously. Reference: WB-2026-X99',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              context.pop(); // go back
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Report Construction',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Warning Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4F4),
                    border: Border.all(color: const Color(0xFFFFDADA)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: AppTheme.danger,
                              fontSize: 11,
                              fontFamily: 'Inter',
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'ANONYMOUS REPORT: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    'Your personal details will not be shared with NBRB or the site owner.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Nature of Violation
                _buildLabel('Nature of Violation'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFEEF2EF),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text(
                        'Select an issue...',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      value: _selectedViolation,
                      items: _violations.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedViolation = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // GPS Location
                _buildLabel('Site Location (GPS)'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '📍 FETCHING SITE COORDINATES...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Upload Evidence
                _buildLabel('Upload Evidence (Photos)'),
                Row(
                  children: [
                    Expanded(
                      child: _buildEvidenceBox(
                        icon: '📸',
                        text: 'TAKE PHOTO',
                        onTap: () {
                          // invoke image picker camera
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildEvidenceBox(
                        icon: '🖼️',
                        text: 'GALLERY',
                        onTap: () {
                          // invoke image picker gallery
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Additional Details
                _buildLabel('Additional Details'),
                TextField(
                  controller: _detailsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe the situation here...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFEEF2EF),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFEEF2EF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'SUBMIT REPORT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildEvidenceBox({
    required String icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF5),
          border: Border.all(
            color: AppTheme.accentGold,
            width: 2,
          ), // dashed usually requires custom painter, using solid here
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 5),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
