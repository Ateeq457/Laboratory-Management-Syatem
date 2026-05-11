// lib/presentation/screens/auth/otp_verification_screen.dart
// ✅ FIXES:
// 1. Fixed double outline issue in OTP boxes
// 2. Professional clean UI
// 3. Same logic preserved

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/core/routes/app_routes.dart';
import 'package:lab_system/data/repositories/firebase_auth_service.dart';
import 'package:lab_system/data/repositories/supabase_auth_repository.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/data/repositories/base_auth_repository.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String userName;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.userName,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final _firebaseAuth = FirebaseAuthService();
  late final SupabaseAuthRepository _supabaseAuth;

  bool _isLoading = false;
  bool _isVerified = false;
  String? _errorMessage;
  int _resendSeconds = 60;
  bool _canResend = false;
  Timer? _timer;

  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _supabaseAuth = locator<BaseAuthRepository>() as SupabaseAuthRepository;
    _startTimer();
    _setupShake();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _setupShake() {
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(0.05, 0)),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(0.05, 0), end: const Offset(-0.05, 0)),
          weight: 2),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(-0.05, 0), end: const Offset(0.05, 0)),
          weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.05, 0), end: Offset.zero),
          weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _resendSeconds = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _resendSeconds--);
      if (_resendSeconds <= 0) {
        t.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (_errorMessage != null) setState(() => _errorMessage = null);

    if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }

    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
      Future.delayed(const Duration(milliseconds: 150), _verifyOTP);
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otp;
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits');
      return;
    }
    if (_isLoading || _isVerified) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final firebaseUser = await _firebaseAuth.verifyOTP(otp);

    if (!mounted) return;

    if (firebaseUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Incorrect OTP. Please check and try again.';
      });
      _shakeController.forward(from: 0);
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
      return;
    }

    final user = await _supabaseAuth.authenticateAfterFirebaseVerification(
      widget.phoneNumber,
    );

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Server error. Please try again.';
      });
      return;
    }

    if (widget.userName.isNotEmpty &&
        (user.name == null || user.name!.trim().isEmpty)) {
      await _supabaseAuth.updateUserProfile(name: widget.userName);
    }

    if (!mounted) return;
    setState(() {
      _isVerified = true;
      _isLoading = false;
    });

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;
    setState(() => _canResend = false);

    final success = await _firebaseAuth.sendOTP(widget.phoneNumber);
    if (!mounted) return;

    if (success) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('OTP resent successfully'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      setState(() => _canResend = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to resend. Try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final phone = widget.phoneNumber;
    final masked = phone.length > 4
        ? '${phone.substring(0, phone.length - 4).replaceAll(RegExp(r'\d'), '*')}${phone.substring(phone.length - 4)}'
        : phone;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    size: 34, color: AppColors.primaryGreen),
              ),

              const SizedBox(height: 20),

              const Text(
                'Verify your number',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),

              const SizedBox(height: 10),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textGray, height: 1.6),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to\n'),
                    TextSpan(
                      text: masked,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ✅ FIXED OTP Row — No double outline
              SlideTransition(
                position: _shakeAnimation,
                child: _buildOtpRow(screenWidth),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 15, color: AppColors.error),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(_errorMessage!,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.error)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isVerified) ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : _isVerified
                          ? const Icon(Icons.check_circle_outline,
                              color: Colors.white)
                          : const Text(
                              'Verify & Continue',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                ),
              ),

              const SizedBox(height: 22),

              _canResend
                  ? GestureDetector(
                      onTap: _resendOTP,
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14),
                          children: [
                            TextSpan(
                                text: "Didn't receive it? ",
                                style: TextStyle(color: AppColors.textGray)),
                            TextSpan(
                              text: 'Resend OTP',
                              style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textGray),
                        children: [
                          const TextSpan(text: 'Resend in '),
                          TextSpan(
                            text: '${_resendSeconds}s',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                    ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FIXED: Professional OTP Row — No double outline
  Widget _buildOtpRow(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (i) => SizedBox(
          width: 45,
          height: 55,
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _errorMessage != null
                      ? AppColors.error
                      : _controllers[i].text.isNotEmpty
                          ? AppColors.primaryGreen
                          : AppColors.borderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primaryGreen, width: 2),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) {
              _onDigitChanged(i, v);
            },
          ),
        ),
      ),
    );
  }
}
