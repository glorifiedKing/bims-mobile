import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme.dart';
import 'professional_copilot_sheet.dart';

class CopilotFloatingAssistant extends StatefulWidget {
  final VoidCallback? onTap;

  const CopilotFloatingAssistant({super.key, this.onTap});

  @override
  State<CopilotFloatingAssistant> createState() =>
      _CopilotFloatingAssistantState();
}

class _CopilotFloatingAssistantState extends State<CopilotFloatingAssistant>
    with TickerProviderStateMixin {
  // Draggable offset position
  Offset _offset = const Offset(16, 90);
  bool _isPressed = false;

  late final AnimationController _heartbeatController;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Heartbeat controller: 2.2s cycle for realistic cardiac rhythm & pulse
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Secondary wave controller: for rotating reactor ring & micro equalizer
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  /// Calculates authentic "lub-dub" heartbeat pulse intensity (0.0 to 1.0)
  double _calculateHeartbeat(double t) {
    // Primary contraction beat: 0.0 -> 0.12
    if (t < 0.12) {
      return math.sin((t / 0.12) * math.pi);
    }
    // Pause between beats: 0.12 -> 0.18
    if (t < 0.18) {
      return 0.0;
    }
    // Secondary contraction beat: 0.18 -> 0.32
    if (t < 0.32) {
      return 0.55 * math.sin(((t - 0.18) / 0.14) * math.pi);
    }
    // Resting relaxation: 0.32 -> 1.0
    return 0.0;
  }

  void _openSheet() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProfessionalCopilotSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: _offset.dx,
      bottom: _offset.dy,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_heartbeatController, _waveController]),
          builder: (context, _) {
            final t = _heartbeatController.value;
            final heartbeat = _calculateHeartbeat(t);
            final wave = _waveController.value;

            // Radar echo ring progress (expands during initial beats)
            final rippleActive = t < 0.45;
            final rippleProgress = rippleActive ? (t / 0.45) : 1.0;
            final rippleScale = 1.0 + (rippleProgress * 0.28);
            final rippleOpacity = rippleActive
                ? (1.0 - rippleProgress) * 0.6
                : 0.0;

            final scale = (_isPressed ? 0.94 : 1.0) + (heartbeat * 0.035);

            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Futuristic expanding radar pulse ripple
                if (rippleActive && rippleOpacity > 0.01)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Transform.scale(
                        scale: rippleScale,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(
                                0xFF00FF9D,
                              ).withValues(alpha: rippleOpacity * 0.7),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF00FF9D,
                                ).withValues(alpha: rippleOpacity * 0.35),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Main futuristic interactive pill
                Transform.scale(
                  scale: scale,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _offset = Offset(
                          (_offset.dx - details.delta.dx).clamp(10.0, 300.0),
                          (_offset.dy - details.delta.dy).clamp(80.0, 600.0),
                        );
                      });
                    },
                    onTapDown: (_) => setState(() => _isPressed = true),
                    onTapUp: (_) => setState(() => _isPressed = false),
                    onTapCancel: () => setState(() => _isPressed = false),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _openSheet();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        // Futuristic multi-tone metallic/neon cyber border
                        gradient: LinearGradient(
                          colors: [
                            const Color(
                              0xFF00FF9D,
                            ).withValues(alpha: 0.7 + 0.3 * heartbeat),
                            AppTheme.accentGold.withValues(alpha: 0.85),
                            const Color(0xFF00E5FF).withValues(alpha: 0.7),
                            const Color(0xFF00FF9D).withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          // Primary neon emerald heartbeat pulse
                          BoxShadow(
                            color: const Color(
                              0xFF00FF9D,
                            ).withValues(alpha: 0.25 + 0.45 * heartbeat),
                            blurRadius: 12.0 + (16.0 * heartbeat),
                            spreadRadius: 0.5 + (3.0 * heartbeat),
                          ),
                          // Secondary cyber gold radiant aura
                          BoxShadow(
                            color: AppTheme.accentGold.withValues(
                              alpha: 0.18 + 0.30 * heartbeat,
                            ),
                            blurRadius: 20.0 + (8.0 * heartbeat),
                            offset: const Offset(0, 2),
                          ),
                          // Cyan edge glow
                          BoxShadow(
                            color: const Color(
                              0xFF00E5FF,
                            ).withValues(alpha: 0.15 + 0.20 * heartbeat),
                            blurRadius: 8.0 + (6.0 * heartbeat),
                          ),
                          // Deep obsidian elevation shadow
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.65),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(1.5), // Border thickness
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28.5),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF031A12), // Deep obsidian jade
                              Color(0xFF0A2B1E), // Emerald cyber slate
                              Color(0xFF031810),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Glass visor top sheen highlight
                            Positioned(
                              top: 0,
                              left: 10,
                              right: 10,
                              height: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: 0.45),
                                      const Color(
                                        0xFF00FF9D,
                                      ).withValues(alpha: 0.6),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Main content
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // AI Quantum Core Orb
                                _buildAiCore(heartbeat, wave),
                                const SizedBox(width: 8),

                                // HUD Typography & Status
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'AI COPILOT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        // Futuristic status chip
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF00FF9D,
                                            ).withValues(alpha: 0.16),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF00FF9D)
                                                  .withValues(
                                                    alpha:
                                                        0.5 + 0.3 * heartbeat,
                                                  ),
                                              width: 0.8,
                                            ),
                                          ),
                                          // child: const Text(
                                          //   'ACTIVE',
                                          //   style: TextStyle(
                                          //     color: Color(0xFF00FF9D),
                                          //     fontSize: 7.5,
                                          //     fontWeight: FontWeight.w900,
                                          //     letterSpacing: 0.6,
                                          //   ),
                                          // ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        //_MicroEqualizer(wave: wave),
                                        const SizedBox(width: 5),
                                        const Text(
                                          'Ask Me',
                                          style: TextStyle(
                                            color: AppTheme.accentGold,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),

                                // Futuristic Chevron
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white.withValues(
                                    alpha: 0.35 + 0.35 * heartbeat,
                                  ),
                                  size: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// High-tech AI Reactor Core Orb with rotating energy field & live beacon
  Widget _buildAiCore(double heartbeat, double wave) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Rotating outer cyber energy field
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                transform: GradientRotation(wave * 2 * math.pi),
                colors: const [
                  Color(0xFF00FF9D),
                  AppTheme.accentGold,
                  Color(0xFF00E5FF),
                  Color(0xFF00FF9D),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF00FF9D,
                  ).withValues(alpha: 0.3 + 0.4 * heartbeat),
                  blurRadius: 6 + (4 * heartbeat),
                ),
              ],
            ),
            padding: const EdgeInsets.all(1.5),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment(-0.2, -0.2),
                  colors: [Color(0xFF083827), Color(0xFF021710)],
                ),
              ),
              child: Center(
                child: Transform.scale(
                  scale: 1.0 + (0.15 * heartbeat),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00FF9D), Color(0xFFE0F7FA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Micro live status beacon on corner
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFF00FF9D),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF021710), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF9D).withValues(alpha: 0.85),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated micro audio/neural equalizer bars simulating real-time AI processing
class _MicroEqualizer extends StatelessWidget {
  final double wave;

  const _MicroEqualizer({required this.wave});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBar(0.0),
        const SizedBox(width: 2),
        _buildBar(0.35),
        const SizedBox(width: 2),
        _buildBar(0.70),
      ],
    );
  }

  Widget _buildBar(double phase) {
    final v = (math.sin((wave + phase) * 2 * math.pi) + 1.0) / 2.0;
    final h = 3.0 + (v * 7.0); // Smooth height oscillation between 3 and 10px
    return Container(
      width: 2.2,
      height: h,
      decoration: BoxDecoration(
        color: Color.lerp(const Color(0xFF00FF9D), AppTheme.accentGold, v),
        borderRadius: BorderRadius.circular(1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF9D).withValues(alpha: 0.45),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }
}
