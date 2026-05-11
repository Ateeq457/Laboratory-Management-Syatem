// lib/presentation/screens/auth/name_input_screen.dart
// Simplified Name Input - Called after signup

import 'package:flutter/material.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/core/routes/app_routes.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/data/repositories/base_auth_repository.dart';

class NameInputScreen extends StatefulWidget {
  final String? email;

  const NameInputScreen({super.key, this.email});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final BaseAuthRepository _authRepo = locator<BaseAuthRepository>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveNameAndProceed() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your name');
      return;
    }

    if (name.length < 2) {
      setState(() =>
          _errorMessage = 'Please enter a valid name (minimum 2 characters)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final updatedUser = await _authRepo.updateUserProfile(name: name);

    setState(() => _isLoading = false);

    if (updatedUser != null && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else {
      setState(() => _errorMessage = 'Failed to save name. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email != null
                      ? 'Welcome ${widget.email}!\nPlease enter your name to continue'
                      : 'Please enter your name to continue',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        size: 20,
                        color: AppColors.textGray,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onSubmitted: (_) => _saveNameAndProceed(),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.error),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveNameAndProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
