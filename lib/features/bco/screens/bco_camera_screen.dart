import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class BcoCameraScreen extends StatefulWidget {
  const BcoCameraScreen({super.key});

  @override
  State<BcoCameraScreen> createState() => _BcoCameraScreenState();
}

class _BcoCameraScreenState extends State<BcoCameraScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera Feed Background
          Container(color: const Color(0xFF333333)),

          // Scan Line Animation
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * _scanAnimation.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold,
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // AR Overlay Boxes
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.3,
            child: _buildArBox(
              color: const Color(0xFF28a745),
              label: 'ACCESSIBILITY: RAMP (1:12 SLOPE) ✓ COMPLIANT',
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: MediaQuery.of(context).size.width * 0.05,
            width: MediaQuery.of(context).size.width * 0.25,
            height: MediaQuery.of(context).size.height * 0.15,
            child: _buildArBox(
              color: AppTheme.accentGold,
              label: 'FIRE EXIT IDENTIFIED',
            ),
          ),

          // Top HUD
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentGold),
                    ),
                    child: const Text(
                      '🤖 AI VISION: ACTIVE (94% CONFIDENCE)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          // Bottom HUD
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plot 14, Mutungo - Commercial Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Permit No: KLA-2026-045-BP | Stage: Superstructure',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push('/bco/stop-order');
                        },
                        icon: const Icon(
                          Icons.block,
                          size: 14,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'STOP ORDER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.danger,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'AI Analysis Frame Saved to BIMS Inspection Log',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push('/bco/checklist');
                        },
                        child: const Text(
                          'CHECKLIST →',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArBox({required Color color, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            left: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
