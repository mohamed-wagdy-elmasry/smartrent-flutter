import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable counter input with (−) / (+) buttons.
///
/// Buttons are LTR-locked (spatial convention: − on left, + on right),
/// but the count + suffix follows the app's text direction so
/// Arabic shows "أيام 4" and English shows "4 Days".
class CounterInput extends StatefulWidget {
  const CounterInput({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.suffixText,
    this.suffixBuilder,
    this.min = 0,
    this.max = 999,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? suffixText;
  final String? Function(int count)? suffixBuilder;
  final int min;
  final int max;

  @override
  State<CounterInput> createState() => _CounterInputState();
}

class _CounterInputState extends State<CounterInput> {
  late int _count;
  int _animKey = 0;
  bool _minusHeld = false;
  bool _plusHeld = false;

  @override
  void initState() {
    super.initState();
    final parsed = int.tryParse(widget.controller.text);
    _count = (parsed != null && parsed >= widget.min) ? parsed : widget.min;
    widget.controller.text = _count.toString();
    widget.controller.addListener(_syncFromController);
  }

  void _syncFromController() {
    final v = int.tryParse(widget.controller.text) ?? 0;
    if (v != _count) setState(() => _count = v);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    super.dispose();
  }

  bool get _atMin => _count <= widget.min;
  bool get _atMax => _count >= widget.max;

  void _change(int delta) {
    final next = _count + delta;
    if (next < widget.min || next > widget.max) return;
    HapticFeedback.lightImpact();
    setState(() {
      _count = next;
      _animKey++;
    });
    widget.controller.text = _count.toString();
  }

  String? get _currentSuffix {
    if (_count <= 0) return null;
    if (widget.suffixBuilder != null) return widget.suffixBuilder!(_count);
    return widget.suffixText;
  }

  @override
  Widget build(BuildContext context) {
    final appDir = Directionality.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ────────────────────────────────────────────────────────
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D1D1D),
          ),
        ),
        const SizedBox(height: 8),

        // ── Counter row (buttons LTR-locked, content natural) ───────────
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE3ECF5), width: 1.2),
            ),
            child: Row(
              children: [
                // ── Minus button ──────────────────────────────────────────
                _StepperButton(
                  icon: Icons.remove_rounded,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  disabled: _atMin,
                  held: _minusHeld,
                  activeBg: const Color(0xFFFFEBEE),
                  activeFg: const Color(0xFF0B5FA5),
                  onDown: () => setState(() => _minusHeld = true),
                  onUp: () {
                    setState(() => _minusHeld = false);
                    _change(-1);
                  },
                  onCancel: () => setState(() => _minusHeld = false),
                ),

                // ── Divider ───────────────────────────────────────────────
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: const Color(0xFFE3ECF5),
                  indent: 12,
                  endIndent: 12,
                ),

                // ── Count + suffix (follows app direction) ───────────────
                Expanded(
                  child: Directionality(
                    textDirection: appDir,
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(_animKey),
                        tween: Tween(begin: 0.78, end: 1.0),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.elasticOut,
                        builder: (_, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: appDir,
                          children: [
                            Text(
                              '$_count',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Color(0xFF0D1B2A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_currentSuffix != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                _currentSuffix!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7A8D),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Divider ───────────────────────────────────────────────
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: const Color(0xFFE3ECF5),
                  indent: 12,
                  endIndent: 12,
                ),

                // ── Plus button ───────────────────────────────────────────
                _StepperButton(
                  icon: Icons.add_rounded,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  disabled: _atMax,
                  held: _plusHeld,
                  activeBg: const Color(0xFFE8F5E9),
                  activeFg: const Color(0xFF4CAF50),
                  onDown: () => setState(() => _plusHeld = true),
                  onUp: () {
                    setState(() => _plusHeld = false);
                    _change(1);
                  },
                  onCancel: () => setState(() => _plusHeld = false),
                ),
              ],
            ),
          ),
        ),

        // ── Hint ─────────────────────────────────────────────────────────
        if (widget.hintText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.hintText!,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9EAAB8),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private stepper button
// ─────────────────────────────────────────────────────────────────────────────

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.borderRadius,
    required this.disabled,
    required this.held,
    required this.activeBg,
    required this.activeFg,
    required this.onDown,
    required this.onUp,
    required this.onCancel,
  });

  final IconData icon;
  final BorderRadius borderRadius;
  final bool disabled;
  final bool held;
  final Color activeBg;
  final Color activeFg;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final Color bg =
        disabled ? Colors.transparent : held ? activeBg : Colors.transparent;
    final Color fg = disabled
        ? const Color(0xFF9EAAB8)
        : held
            ? activeFg
            : const Color(0xFF0D1B2A);

    return GestureDetector(
      onTapDown: disabled ? null : (_) => onDown(),
      onTapUp: disabled ? null : (_) => onUp(),
      onTapCancel: disabled ? null : onCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: bg, borderRadius: borderRadius),
        child: Icon(icon, size: 22, color: fg),
      ),
    );
  }
}