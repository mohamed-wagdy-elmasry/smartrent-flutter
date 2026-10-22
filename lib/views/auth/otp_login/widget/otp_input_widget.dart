part of '../screen/otp_login_screen.dart';

class OtpInputWidget extends StatefulWidget {
  const OtpInputWidget({super.key});

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  final OtpLoginController _ctrl = Get.find<OtpLoginController>();
  static const _resendCooldown = 30;
  int _seconds = _resendCooldown;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _seconds = _resendCooldown;
    _canResend = false;
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_seconds > 0) {
          _seconds--;
          _tick();
        } else {
          _canResend = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone confirmation chip
        Obx(() => _PhoneChip(
          phone: '${_ctrl.mobileCode.value} ${_ctrl.mobileController.text}',
          onEdit: () {
            _ctrl.isOtpSent.value = false;
            _ctrl.otp.value = '';
            _ctrl.otpController.clear();
          },
        )),
        const SizedBox(height: 22),

        // PIN boxes
        PinCodeTextField(
          appContext: context,
          controller: _ctrl.otpController,
          length: 6,
          keyboardType: TextInputType.number,
          enableActiveFill: true,
          autoFocus: true,
          animationType: AnimationType.scale,
          animationDuration: const Duration(milliseconds: 180),
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: _R.pinRadius,
            fieldHeight: 54,
            fieldWidth: 46,
            activeFillColor: Colors.white,
            selectedFillColor: Colors.white,
            inactiveFillColor: _C.pinIdle,
            activeColor: CustomColor.primary,
            selectedColor: CustomColor.primary,
            inactiveColor: _C.pinBorder,
            borderWidth: 1.5,
          ),
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CustomColor.typography,
          ),
          onChanged: (value) => _ctrl.otp.value = value,
          onCompleted: (value) => _ctrl.otp.value = value,
        ),
        const SizedBox(height: 18),

        // Resend row
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              Strings.didntGetTheCode,
              typographyStyle: TypographyStyle.bodyMedium,
              colorShade: ColorShade.mediumForty,
            ),
            const SizedBox(width: 8),
            if (_ctrl.isResending)
              SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CustomColor.primary,
                ),
              )
            else if (_canResend)
              GestureDetector(
                onTap: () {
                  setState(_startCountdown);
                  _ctrl.resendOtpProcess();
                },
                child: TextWidget(
                  DynamicLanguage.key(Strings.resendOtp),
                  typographyStyle: TypographyStyle.bodyMedium,
                  color: CustomColor.primary,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              TextWidget(
                '${DynamicLanguage.key(Strings.resendOtp)} ($_seconds s)',
                typographyStyle: TypographyStyle.bodyMedium,
                color: _C.stepText,
                fontWeight: FontWeight.w500,
              ),
          ],
        )),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Chip showing the phone number with a WhatsApp icon and edit option
class _PhoneChip extends StatelessWidget {
  final String phone;
  final VoidCallback onEdit;
  const _PhoneChip({required this.phone, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: CustomColor.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColor.primary.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sms_rounded, color: _C.waGreen, size: 18),
          const SizedBox(width: 8),
          Text(
            phone,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: CustomColor.typography,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onEdit,
            child: Icon(Icons.edit_rounded, size: 15, color: CustomColor.primary),
          ),
        ],
      ),
    );
  }
}
