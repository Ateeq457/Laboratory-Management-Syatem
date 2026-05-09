// lib/presentation/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:lab_system/core/themes/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.primaryMid],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'AS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ahmad Raza',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '+92 300 1234567',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 24),
            // Profile Options
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _buildProfileOption(
                      Icons.person_outline, 'Personal Information', () {}),
                  _buildDivider(),
                  _buildProfileOption(
                      Icons.location_on_outlined, 'Saved Addresses', () {}),
                  _buildDivider(),
                  _buildProfileOption(
                      Icons.notifications_none, 'Notifications', () {}),
                  _buildDivider(),
                  _buildProfileOption(Icons.security, 'Privacy Policy', () {}),
                  _buildDivider(),
                  _buildProfileOption(Icons.logout, 'Logout', () {},
                      isLogout: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? AppColors.error : AppColors.primaryGreen,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isLogout ? AppColors.error : AppColors.textDark,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isLogout ? AppColors.error : AppColors.textLightGray,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 0,
      thickness: 0.5,
      color: AppColors.borderLight,
    );
  }
}
