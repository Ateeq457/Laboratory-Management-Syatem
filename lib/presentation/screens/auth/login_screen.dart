// lib/presentation/screens/auth/login_screen.dart
// ✅ Professional Login Screen
// - Full name + phone number on ONE screen (as requested)
// - Pakistan country code prefix (+92)
// - Real-time phone validation before sending OTP
// - Passes name forward to OTP screen (stored after OTP success)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/data/repositories/firebase_auth_service.dart';
import 'package:lab_system/presentation/screens/auth/otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _firebaseAuth = FirebaseAuthService();

  bool _isLoading = false;
  String? _phoneError;
  String? _nameError;

  // Country code — hardcoded to Pakistan, can be made a picker
  final String _countryCode = '+92';
  final String _countryFlag = '🇵🇰';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ─── Validation ─────────────────────────────────────────────

  String? _validateName(String name) {
    if (name.trim().isEmpty) return 'Please enter your full name';
    if (name.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validatePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return 'Please enter your mobile number';
    if (digits.length < 10) return 'Number too short — enter 10 digits';
    if (digits.length > 10) return 'Number too long — enter 10 digits';
    if (!digits.startsWith('3')) {
      return 'Pakistani numbers start with 03XX — enter digits after 0';
    }
    return null;
  }

  // ─── Send OTP ────────────────────────────────────────────────

  Future<void> _sendOTP() async {
    // Clear old errors
    setState(() {
      _nameError = null;
      _phoneError = null;
    });

    final nameErr = _validateName(_nameController.text);
    final phoneErr = _validatePhone(_phoneController.text.trim());

    if (nameErr != null || phoneErr != null) {
      setState(() {
        _nameError = nameErr;
        _phoneError = phoneErr;
      });
      return;
    }

    setState(() => _isLoading = true);

    // Build full number — user enters 10 digits starting with 3
    final rawPhone =
        _phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    final fullPhone = '$_countryCode$rawPhone'; // e.g. +923001234567

    final success = await _firebaseAuth.sendOTP(fullPhone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            phoneNumber: fullPhone,
            userName: _nameController.text.trim(),
          ),
        ),
      );
    } else {
      setState(() {
        _phoneError =
            'Could not send OTP. Check the number or try again later.';
      });
    }
  }

  // ─── UI ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // ── Logo + Title ─────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 20),
                        const Text(
                          'Welcome to Thal-Care',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter your details to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Name Field ───────────────────────────────
                  _buildSectionLabel('Full Name'),
                  const SizedBox(height: 8),
                  _buildNameField(),
                  if (_nameError != null) _buildError(_nameError!),

                  const SizedBox(height: 20),

                  // ── Phone Field ──────────────────────────────
                  _buildSectionLabel('Mobile Number'),
                  const SizedBox(height: 8),
                  _buildPhoneField(),
                  if (_phoneError != null) _buildError(_phoneError!),

                  const SizedBox(height: 12),

                  // Phone hint
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Enter 10-digit number e.g. 3001234567',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLightGray,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── CTA Button ───────────────────────────────
                  _buildSendOTPButton(),

                  const SizedBox(height: 24),

                  // ── Terms ────────────────────────────────────
                  Center(
                    child: Text(
                      'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLightGray,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 28,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              width: 10,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _nameError != null ? AppColors.error : AppColors.borderLight,
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.name,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        onChanged: (_) {
          if (_nameError != null) setState(() => _nameError = null);
        },
        decoration: const InputDecoration(
          hintText: 'e.g. Ahmed Raza',
          hintStyle: TextStyle(
            color: AppColors.textLightGray,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _phoneError != null ? AppColors.error : AppColors.borderLight,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Country code badge
          Container(
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_countryFlag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  _countryCode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 24,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: AppColors.borderLight,
          ),

          // Number input
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
                letterSpacing: 1,
              ),
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
              decoration: const InputDecoration(
                hintText: '3001234567',
                hintStyle: TextStyle(
                  color: AppColors.textLightGray,
                  fontSize: 14,
                  letterSpacing: 0,
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 13, color: AppColors.error),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendOTPButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          disabledBackgroundColor: AppColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: AppColors.primaryGreen.withOpacity(0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Send OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded,
                      size: 18, color: Colors.white),
                ],
              ),
      ),
    );
  }
}
