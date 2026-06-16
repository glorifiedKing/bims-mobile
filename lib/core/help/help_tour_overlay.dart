import 'package:flutter/material.dart';
import '../theme.dart';
import 'help_controller.dart';
import 'help_step.dart';

// ─── Spotlight custom painter ────────────────────────────────────────────────

class _SpotlightPainter extends CustomPainter {
  final Rect? spotlightRect;
  final bool isCircle;
  final double animValue;

  static const double _borderRadius = 12;

  const _SpotlightPainter({
    required this.spotlightRect,
    required this.isCircle,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.72 * animValue);

    if (spotlightRect != null) {
      final inflated = spotlightRect!.inflate(6);

      // Draw dimmed overlay with a cut-out hole
      final Path overlayPath;
      if (isCircle) {
        final radius = (inflated.width > inflated.height ? inflated.width : inflated.height) / 2;
        final center = inflated.center;
        overlayPath = Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
        );
      } else {
        overlayPath = Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()..addRRect(RRect.fromRectAndRadius(inflated, Radius.circular(_borderRadius))),
        );
      }
      canvas.drawPath(overlayPath, overlayPaint);

      // Draw glowing border around the spotlight
      final borderPaint = Paint()
        ..color = AppTheme.accentGold.withOpacity(0.85 * animValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      if (isCircle) {
        final radius = (inflated.width > inflated.height ? inflated.width : inflated.height) / 2;
        canvas.drawCircle(inflated.center, radius, borderPaint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(inflated, Radius.circular(_borderRadius)),
          borderPaint,
        );
      }
    } else {
      // No target — just full-screen dim
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        overlayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) =>
      old.spotlightRect != spotlightRect ||
      old.animValue != animValue ||
      old.isCircle != isCircle;
}

// ─── Main overlay widget ─────────────────────────────────────────────────────

/// Wrap your screen's [Scaffold] body (or the [Scaffold] itself) with this
/// widget and pass a [HelpController].  Call [controller.start(steps)] to
/// begin the tour.
class HelpTourOverlay extends StatefulWidget {
  final Widget child;
  final HelpController controller;

  const HelpTourOverlay({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<HelpTourOverlay> createState() => _HelpTourOverlayState();
}

class _HelpTourOverlayState extends State<HelpTourOverlay>
    with TickerProviderStateMixin {
  Rect? _targetRect;
  late AnimationController _fadeCtrl;
  late AnimationController _cardCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _cardSlideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));

    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _fadeCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (widget.controller.isActive) {
      _resolveTargetRect();
      _fadeCtrl.forward();
      _cardCtrl.forward(from: 0);
    } else {
      _fadeCtrl.reverse();
    }
    setState(() {});
  }

  void _resolveTargetRect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final step = widget.controller.currentStep;
      if (step == null || step.targetKey == null) {
        if (mounted) setState(() => _targetRect = null);
        return;
      }
      final ctx = step.targetKey!.currentContext;
      if (ctx == null) {
        if (mounted) setState(() => _targetRect = null);
        return;
      }
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) return;
      final pos = box.localToGlobal(Offset.zero);
      final sz = box.size;
      final p = step.padding;
      if (mounted) {
        setState(() {
          _targetRect = Rect.fromLTWH(
            pos.dx - p.left,
            pos.dy - p.top,
            sz.width + p.horizontal,
            sz.height + p.vertical,
          );
        });
      }
    });
  }

  // ── Card positioning ──────────────────────────────────────────────────────

  /// Returns a top offset for the help card based on spotlight position.
  double _cardTop(Size screen, double cardHeight) {
    final step = widget.controller.currentStep;
    if (step == null || _targetRect == null) {
      return (screen.height - cardHeight) / 2;
    }

    switch (step.cardPosition) {
      case HelpCardPosition.top:
        return (_targetRect!.top - cardHeight - 24).clamp(80.0, screen.height - cardHeight - 24);
      case HelpCardPosition.bottom:
        return (_targetRect!.bottom + 24).clamp(80.0, screen.height - cardHeight - 24);
      case HelpCardPosition.center:
        return (screen.height - cardHeight) / 2;
      case HelpCardPosition.auto:
        // Put below the spotlight if there's space, otherwise above
        final spaceBelow = screen.height - _targetRect!.bottom - 24;
        if (spaceBelow >= cardHeight + 24) {
          return _targetRect!.bottom + 24;
        }
        final above = _targetRect!.top - cardHeight - 24;
        if (above >= 80) return above;
        // Not enough space either side — centre it
        return (screen.height - cardHeight) / 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Stack(
          children: [
            widget.child,
            if (widget.controller.isActive) ...[
              // ── Dimmed backdrop with spotlight ──
              Positioned.fill(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (_, __) => CustomPaint(
                      painter: _SpotlightPainter(
                        spotlightRect: _targetRect,
                        isCircle: widget.controller.currentStep?.circleSpotlight ?? false,
                        animValue: _fadeAnim.value,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Tap anywhere (outside card) to go next ──
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.controller.next,
                  child: const SizedBox.expand(),
                ),
              ),

              // ── Help card ──
              _HelpCard(
                controller: widget.controller,
                cardTop: _cardTop,
                cardSlideAnim: _cardSlideAnim,
                fadeAnim: _fadeAnim,
              ),
            ],
          ],
        );
      },
    );
  }
}

// ─── Help card widget ─────────────────────────────────────────────────────────

class _HelpCard extends StatelessWidget {
  final HelpController controller;
  final double Function(Size, double) cardTop;
  final Animation<Offset> cardSlideAnim;
  final Animation<double> fadeAnim;

  const _HelpCard({
    required this.controller,
    required this.cardTop,
    required this.cardSlideAnim,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    final step = controller.currentStep;
    if (step == null) return const SizedBox.shrink();

    final screen = MediaQuery.of(context).size;
    const cardWidth = 320.0;
    const estimatedCardHeight = 200.0;

    final leftOffset = ((screen.width - cardWidth) / 2).clamp(16.0, screen.width - cardWidth - 16);
    final topOffset = cardTop(screen, estimatedCardHeight);

    return Positioned(
      left: leftOffset,
      top: topOffset,
      width: cardWidth,
      child: FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(
          position: cardSlideAnim,
          child: _buildCard(context, step),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, HelpStep step) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card header ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00331a), AppTheme.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  if (step.emoji != null) ...[
                    Text(step.emoji!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      step.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Step counter pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.currentIndex + 1} / ${controller.totalSteps}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar ──
            LinearProgressIndicator(
              value: controller.totalSteps > 0
                  ? (controller.currentIndex + 1) / controller.totalSteps
                  : 0,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation(AppTheme.accentGold),
              minHeight: 3,
            ),

            // ── Description ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Text(
                step.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF444444),
                  height: 1.55,
                ),
              ),
            ),

            // ── Action buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // Dismiss / Skip button
                  TextButton(
                    onPressed: controller.dismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      'SKIP',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const Spacer(),

                  // Back button (hidden on first step)
                  if (!controller.isFirstStep) ...[
                    OutlinedButton(
                      onPressed: controller.previous,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        side: const BorderSide(color: AppTheme.primaryGreen),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'BACK',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Next / Done button
                  ElevatedButton(
                    onPressed: controller.next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size.zero,
                      elevation: 0,
                    ),
                    child: Text(
                      controller.isLastStep ? 'DONE ✓' : 'NEXT →',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Convenience help button ──────────────────────────────────────────────────

/// A small circular "?" button you can drop into any AppBar or header.
class HelpIconButton extends StatelessWidget {
  final HelpController controller;
  final List<HelpStep> steps;
  final Color? color;

  const HelpIconButton({
    super.key,
    required this.controller,
    required this.steps,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.start(steps),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (color ?? Colors.white).withOpacity(0.2),
          border: Border.all(
            color: (color ?? Colors.white).withOpacity(0.6),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
              color: color ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
