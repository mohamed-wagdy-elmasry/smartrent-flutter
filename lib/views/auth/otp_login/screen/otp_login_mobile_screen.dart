part of '../screen/otp_login_screen.dart';

// ─── Design Tokens (shared across all part files in this library) ─────────────
class _C {
  static final heroTop      = CustomColor.primary;
  static final heroBottom   = const Color(0xFF073B6E);
  static final waGreen      = const Color(0xFF25D366);
  static final successGreen = const Color(0xFF27B059);
  static final stepInactive = const Color(0xFFDDE3EA);
  static final stepText     = const Color(0xFF9AADBE);
  static final cardBg       = Colors.white;
  static final pinIdle      = const Color(0xFFF0F4F8);
  static final pinBorder    = const Color(0xFFDDE3EA);
}

class _R {
  static const cardRadius  = Radius.circular(32);
  static const pinRadius   = BorderRadius.all(Radius.circular(14));
  static const badgeRadius = BorderRadius.all(Radius.circular(20));
}

// ─── Mobile Screen ────────────────────────────────────────────────────────────
class OtpLoginMobileScreen extends GetView<OtpLoginController> {
  const OtpLoginMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: _C.heroTop,
      body: Stack(
        children: [
          // Gradient hero background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_C.heroTop, _C.heroBottom],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Hero section
                SizedBox(
                  height: screenH * 0.28,
                  child: const _HeroSection(),
                ),
                // Form card
                Expanded(child: _buildFormCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: const BorderRadius.only(
          topLeft:  _R.cardRadius,
          topRight: _R.cardRadius,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepIndicator(),
            const SizedBox(height: 22),
            const HeadingWidget(),
            const SizedBox(height: 24),
            Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              transitionBuilder: (child, anim) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: controller.isOtpSent.value
                  ? const OtpInputWidget(key: ValueKey('otp'))
                  : const MobileInputWidget(key: ValueKey('phone')),
            )),
            const SizedBox(height: 8),
            const LoginButtonWidget(),
            const SizedBox(height: 20),
            const HaveAccountWidget(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const BrandLogo(),
        const SizedBox(height: 14),
        _WaBadge(),
      ],
    );
  }
}

class _WaBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: const BoxDecoration(
        color: Color(0x21FFFFFF),
        borderRadius: _R.badgeRadius,
        border: Border.fromBorderSide(BorderSide(color: Color(0x33FFFFFF))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sms_rounded, color: _C.waGreen, size: 15),
          const SizedBox(width: 7),
          const Text(
            'SMS Verification',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────
class _StepIndicator extends GetView<OtpLoginController> {
  const _StepIndicator();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = controller.isOtpSent.value ? 2 : 1;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepDot(label: '1', index: 1, current: step),
          _StepConnector(active: step >= 2),
          _StepDot(label: '2', index: 2, current: step),
          _StepConnector(active: false),
          _StepDot(label: '3', index: 3, current: step),
        ],
      );
    });
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  const _StepDot({required this.label, required this.index, required this.current});

  bool get _done   => current > index;
  bool get _active => current == index;

  @override
  Widget build(BuildContext context) {
    final bg = _done
        ? _C.successGreen
        : _active
            ? CustomColor.primary
            : _C.stepInactive;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width:  _active ? 34 : 26,
      height: _active ? 34 : 26,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Center(
        child: _done
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
            : Text(
                label,
                style: TextStyle(
                  fontSize: _active ? 13 : 11,
                  fontWeight: FontWeight.bold,
                  color: _active ? Colors.white : _C.stepText,
                ),
              ),
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool active;
  const _StepConnector({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 2,
      width: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active ? CustomColor.primary : _C.stepInactive,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
