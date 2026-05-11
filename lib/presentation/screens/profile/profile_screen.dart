// lib/presentation/screens/profile/profile_screen.dart
// Simplified Profile Screen - Name and Email only

import 'package:flutter/material.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/core/routes/app_routes.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/data/repositories/base_auth_repository.dart';
import 'package:lab_system/data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final BaseAuthRepository _authRepo = locator<BaseAuthRepository>();

  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authRepo.getCurrentUser();
      setState(() {
        _user = user;
        _nameController.text = user?.name ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _updateName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    if (newName == _user?.name) {
      setState(() => _isEditing = false);
      return;
    }

    setState(() => _isLoading = true);

    final updatedUser = await _authRepo.updateUserProfile(name: newName);

    setState(() {
      _user = updatedUser;
      _isLoading = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Name updated successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      await _authRepo.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildAvatarSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                  _buildVersionInfo(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryGreen),
          SizedBox(height: 16),
          Text('Loading profile...',
              style: TextStyle(color: AppColors.textGray)),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final userName = _user?.name ?? 'Guest User';
    final userEmail = _user?.email ?? 'No email';

    String initials = 'U';
    if (userName.isNotEmpty && userName != 'Guest User') {
      final nameParts = userName.split(' ');
      if (nameParts.length >= 2) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else {
        initials = userName[0].toUpperCase();
      }
    }

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.primaryMid]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600))),
        ),
        const SizedBox(height: 16),
        if (_isEditing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.check, color: AppColors.success),
                  onPressed: _updateName,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _nameController.text = _user?.name ?? '';
                    });
                  },
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: () => setState(() => _isEditing = true),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(userName,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 16, color: AppColors.primaryGreen),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(userEmail,
            style: const TextStyle(fontSize: 14, color: AppColors.textGray)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Logout',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        const Text('Version 1.0.0',
            style: TextStyle(fontSize: 11, color: AppColors.textLightGray)),
        const SizedBox(height: 4),
        Text('© 2024 Thal-Care Diagnostic Services',
            style: TextStyle(
                fontSize: 10, color: AppColors.textLightGray.withOpacity(0.7))),
      ],
    );
  }
}
