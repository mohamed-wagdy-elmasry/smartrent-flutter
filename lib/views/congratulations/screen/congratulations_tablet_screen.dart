part of 'congratulations_screen.dart';

class CongratulationsTabletScreen extends StatefulWidget {
  const CongratulationsTabletScreen({super.key});

  @override
  State<CongratulationsTabletScreen> createState() =>
      _CongratulationsTabletScreenState();
}

class _CongratulationsTabletScreenState
    extends State<CongratulationsTabletScreen> with TickerProviderStateMixin {
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

    _badgeScale = CurvedAnimation(parent: _badgeCtrl, curve: Curves.elasticOut);
    _badgeFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _badgeCtrl, curve: const Interval(0, 0.4)));
    _cardSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
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
            // Tablet: side-by-side layout
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      // Left: badge
                      Expanded(
                        flex: 45,
                        child: _BadgeSection(
                          badgeScale: _badgeScale,
                          badgeFade: _badgeFade,
                          pulse: _pulse,
                          pulseCtrl: _pulseCtrl,
                          isSuccess: isSuccess,
                        ),
                      ),
                      // Right: card
                      Expanded(
                        flex: 55,
                        child: Padding(
                          padding: const EdgeInsets.all(_S.md),
                          child: SlideTransition(
                            position: _cardSlide,
                            child: FadeTransition(
                              opacity: _cardFade,
                              child: _TabletCard(
                                ctrl: _ctrl,
                                isSuccess: isSuccess,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletCard extends StatelessWidget {
  final CongratulationsController ctrl;
  final bool isSuccess;
  const _TabletCard({required this.ctrl, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: _C.cardShadow,
            blurRadius: 40,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(_S.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _StatusPill(
            label: ctrl.congratulationDetails.value.type,
            isSuccess: isSuccess,
          ),
          const SizedBox(height: _S.md),
          Text(
            isSuccess ? 'Booking Confirmed!' : 'Action Required',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: _S.sm + 2),
          Text(
            ctrl.congratulationDetails.value.details,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: _C.textSecondary,
              height: 1.65,
            ),
          ),
          const SizedBox(height: _S.lg),
          _CarDivider(isSuccess: isSuccess),
          const SizedBox(height: _S.xl),
          _CtaButton(ctrl: ctrl, isSuccess: isSuccess),
        ],
      ),
    );
  }
}

