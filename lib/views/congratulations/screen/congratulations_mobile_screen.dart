part of 'congratulations_screen.dart';

// ─── Design tokens (screen-local) ────────────────────────────────────────────
class _C {
  static const Color successGreen = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color surface = Color(0xFFF9FAFB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFF3F4F6);
  static const Color cardShadow = Color(0x18000000);
}

class _S {
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}

// ─── Mobile Screen ────────────────────────────────────────────────────────────
class CongratulationsMobileScreen extends StatefulWidget {
  const CongratulationsMobileScreen({super.key});

  @override
  State<CongratulationsMobileScreen> createState() =>
      _CongratulationsMobileScreenState();
}

class _CongratulationsMobileScreenState
    extends State<CongratulationsMobileScreen> with TickerProviderStateMixin {
  late final CongratulationsController _ctrl;
  late final AnimationController _badgeCtrl;
  late final AnimationController _cardCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _badgeScale;
  late final Animation<double> _badgeFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(CongratulationsController());

    _badgeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);

    _badgeScale = CurvedAnimation(
        parent: _badgeCtrl, curve: Curves.elasticOut);
    _badgeFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _badgeCtrl, curve: const Interval(0, 0.4)));
    _cardSlide =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
            CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeIn));
    _pulse = Tween<double>(begin: 0.94, end: 1.06).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _badgeCtrl.forward();
      Future.delayed(const Duration(milliseconds: 300),
          () { if (mounted) _cardCtrl.forward(); });
    });
  }

  @override
  void dispose() {
    _badgeCtrl.dispose();
    _cardCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get _isSuccess {
    final t = _ctrl.congratulationDetails.value.type.toLowerCase();
    return t.contains('success') ||
        t.contains('confirm') ||
        t.contains('payment') ||
        t.contains('book');
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = _isSuccess;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => Get.offAllNamed(Routes.dashboardScreen),
      child: Scaffold(
        body: Stack(
          children: [
            _GradientBg(isSuccess: isSuccess),
            _DecorCircles(isSuccess: isSuccess),
            Column(
              children: [
                // ── Hero badge area ──────────────────────────────────────
                Expanded(
                  flex: 38,
                  child: SafeArea(
                    bottom: false,
                    child: _BadgeSection(
                      badgeScale: _badgeScale,
                      badgeFade: _badgeFade,
                      pulse: _pulse,
                      pulseCtrl: _pulseCtrl,
                      isSuccess: isSuccess,
                    ),
                  ),
                ),
                // ── Bottom card ──────────────────────────────────────────
                Expanded(
                  flex: 62,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: FadeTransition(
                      opacity: _cardFade,
                      child: _BottomCard(
                        ctrl: _ctrl,
                        isSuccess: isSuccess,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Gradient background ───────────────────────────────────────────────────
class _GradientBg extends StatelessWidget {
  final bool isSuccess;
  const _GradientBg({required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final top = isSuccess ? CustomColor.primary : const Color(0xFFC62828);
    final bottom = isSuccess ? const Color(0xFF073A65) : const Color(0xFF7F0000);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

// ─── Decorative circles ────────────────────────────────────────────────────
class _DecorCircles extends StatelessWidget {
  final bool isSuccess;
  const _DecorCircles({required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CircleDecorPainter(
            accent: isSuccess ? CustomColor.secondary : const Color(0xFFEF5350),
          ),
        ),
      ),
    );
  }
}

class _CircleDecorPainter extends CustomPainter {
  final Color accent;
  const _CircleDecorPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    void draw(double x, double y, double r, double opacity) {
      canvas.drawCircle(
        Offset(size.width * x, size.height * y),
        r,
        Paint()..color = accent.withOpacity(opacity),
      );
    }

    // Soft blobs
    draw(1.1, 0.04, 120, 0.07);
    draw(-0.1, 0.18, 90, 0.06);
    draw(0.6, 0.30, 50, 0.05);
    draw(0.15, 0.08, 45, 0.04);
    // Tiny sparkle dots
    draw(0.82, 0.14, 6, 0.18);
    draw(0.22, 0.25, 5, 0.14);
    draw(0.48, 0.10, 4, 0.16);
  }

  @override
  bool shouldRepaint(_CircleDecorPainter old) => old.accent != accent;
}

// ─── Badge section ─────────────────────────────────────────────────────────
class _BadgeSection extends StatelessWidget {
  final Animation<double> badgeScale;
  final Animation<double> badgeFade;
  final Animation<double> pulse;
  final AnimationController pulseCtrl;
  final bool isSuccess;

  const _BadgeSection({
    required this.badgeScale,
    required this.badgeFade,
    required this.pulse,
    required this.pulseCtrl,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: badgeFade,
        child: ScaleTransition(
          scale: badgeScale,
          child: AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, __) => _BadgeWidget(
              pulse: pulse.value,
              isSuccess: isSuccess,
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeWidget extends StatelessWidget {
  final double pulse;
  final bool isSuccess;
  const _BadgeWidget({required this.pulse, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isSuccess ? const Color(0xFF22C55E) : const Color(0xFFEF5350);
    final glowColor =
        isSuccess ? const Color(0xFF22C55E) : const Color(0xFFEF5350);

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outermost pulsing ring
          Transform.scale(
            scale: pulse,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          // Mid ring
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          // Inner white circle with glow
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.45),
                  blurRadius: 28,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                isSuccess ? Assets.icons.success : Assets.icons.reject,
                height: 48,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom card ───────────────────────────────────────────────────────────
class _BottomCard extends StatelessWidget {
  final CongratulationsController ctrl;
  final bool isSuccess;
  const _BottomCard({required this.ctrl, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: _C.cardShadow,
            blurRadius: 40,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            _S.lg, _S.lg, _S.lg, _S.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: _S.lg),

            // Status pill
            _StatusPill(
              label: ctrl.congratulationDetails.value.type,
              isSuccess: isSuccess,
            ),
            const SizedBox(height: _S.md),

            // Headline
            Text(
              isSuccess ? 'Booking Confirmed!' : 'Action Required',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _C.textPrimary,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: _S.sm + 2),

            // Message
            Text(
              ctrl.congratulationDetails.value.details,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                color: _C.textSecondary,
                height: 1.65,
              ),
            ),
            const SizedBox(height: _S.lg + _S.sm),

            // Decorative divider
            _CarDivider(isSuccess: isSuccess),
            const SizedBox(height: _S.lg + _S.sm),

            // CTA button
            _CtaButton(ctrl: ctrl, isSuccess: isSuccess),
          ],
        ),
      ),
    );
  }
}

// ─── Status pill ───────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final String label;
  final bool isSuccess;
  const _StatusPill({required this.label, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: isSuccess ? _C.successBg : _C.errorBg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: (isSuccess ? _C.successGreen : _C.errorRed).withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle_rounded
                : Icons.error_rounded,
            size: 14,
            color: isSuccess ? _C.successGreen : _C.errorRed,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isSuccess ? _C.successGreen : _C.errorRed,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Car divider ───────────────────────────────────────────────────────────
class _CarDivider extends StatelessWidget {
  final bool isSuccess;
  const _CarDivider({required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, _C.divider],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _C.surface,
            shape: BoxShape.circle,
            border: Border.all(color: _C.divider, width: 1.5),
          ),
          child: Icon(
            Icons.directions_car_rounded,
            size: 16,
            color: CustomColor.primary.withOpacity(0.5),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_C.divider, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}



// ─── CTA buttons ───────────────────────────────────────────────────────────
class _CtaButton extends StatelessWidget {
  final CongratulationsController ctrl;
  final bool isSuccess;
  const _CtaButton({required this.ctrl, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary: My Bookings (success) / Home (error)
        SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isSuccess
                    ? [CustomColor.primary, const Color(0xFF0A3D6B)]
                    : [const Color(0xFFC62828), const Color(0xFF7F0000)],
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isSuccess ? CustomColor.primary : const Color(0xFFC62828))
                          .withOpacity(0.38),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => Get.offAllNamed(
                isSuccess ? Routes.historyScreen : Routes.dashboardScreen,
              ),
              icon: Icon(
                isSuccess ? Icons.receipt_long_rounded : Icons.home_rounded,
                size: 20,
                color: Colors.white,
              ),
              label: Obx(() {
                final isAr = DynamicLanguage.selectedLanguage.value == 'ar';
                return Text(
                  isSuccess
                      ? (isAr ? 'سجلاتي' : 'My Bookings')
                      : (isAr ? 'الرئيسية' : 'Home'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                );
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
        // Secondary: Home (success only)
        if (isSuccess) ...[
          const SizedBox(height: _S.sm),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => Get.offAllNamed(Routes.dashboardScreen),
              icon: Icon(Icons.home_rounded, size: 20, color: CustomColor.primary),
              label: Obx(() {
                final isAr = DynamicLanguage.selectedLanguage.value == 'ar';
                return Text(
                  isAr ? 'الرئيسية' : 'Home',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CustomColor.primary,
                  ),
                );
              }),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: CustomColor.primary.withOpacity(0.4),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

