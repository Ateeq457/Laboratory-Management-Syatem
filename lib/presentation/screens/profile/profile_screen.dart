// lib/presentation/screens/profile/profile_screen.dart
// Fully Dynamic Profile Screen - Works with JSON & Supabase

import 'package:flutter/material.dart';
import 'package:lab_system/core/themes/app_theme.dart';
import 'package:lab_system/core/routes/app_routes.dart';
import 'package:lab_system/services/locator.dart';
import 'package:lab_system/data/repositories/base_auth_repository.dart';
import 'package:lab_system/data/repositories/base_booking_repository.dart';
import 'package:lab_system/data/models/booking_model.dart';
import 'package:lab_system/data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final BaseAuthRepository _authRepo = locator<BaseAuthRepository>();
  final BaseBookingRepository _bookingRepo = locator<BaseBookingRepository>();

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  // Stats
  int _totalBookings = 0;
  int _completedBookings = 0;
  int _activeBookings = 0;
  int _cancelledBookings = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load user from auth repository
      final user = await _authRepo.getCurrentUser();

      // Load bookings for stats
      if (user != null) {
        final bookings = await _bookingRepo.getUserBookings(user.id);
        _calculateStats(bookings);
      }

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile data';
        _isLoading = false;
      });
      debugPrint('Error loading profile: $e');
    }
  }

  void _calculateStats(List<BookingModel> bookings) {
    _totalBookings = bookings.length;
    _completedBookings =
        bookings.where((b) => b.status == BookingStatus.completed).length;
    _activeBookings = bookings
        .where((b) =>
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.sampleCollected ||
            b.status == BookingStatus.processing)
        .length;
    _cancelledBookings =
        bookings.where((b) => b.status == BookingStatus.cancelled).length;
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      await _authRepo.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  void _navigateToPersonalInfo() {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit Profile - Coming Soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToSavedAddresses() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved Addresses - Coming Soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications Settings - Coming Soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information when you use our app.\n\n'
            '1. Information we collect: Phone number, name, address, and test records.\n'
            '2. How we use your information: To provide diagnostic services, process bookings, and deliver reports.\n'
            '3. Data security: We use industry-standard encryption to protect your data.\n'
            '4. Your rights: You can request deletion of your data at any time.\n\n'
            'For any questions, contact us at support@thal-care.com',
            style: TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primaryGreen),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings - Coming Soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryGreen),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(color: AppColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: AppColors.textGray),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildAvatarSection(),
          const SizedBox(height: 24),
          _buildStatsSection(),
          const SizedBox(height: 24),
          _buildProfileOptions(),
          const SizedBox(height: 30),
          _buildVersionInfo(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final userName = _user?.name ?? 'Guest User';
    final userPhone = _user?.phone ?? 'Not provided';

    // Get initials from name
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
              colors: [AppColors.primaryGreen, AppColors.primaryMid],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userPhone,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textGray,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _navigateToPersonalInfo,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryGreen),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          child: const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              'Total', _totalBookings.toString(), Icons.receipt_long),
          _buildVerticalDivider(),
          _buildStatItem(
              'Completed', _completedBookings.toString(), Icons.check_circle),
          _buildVerticalDivider(),
          _buildStatItem('Active', _activeBookings.toString(), Icons.pending),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryGreen),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.borderLight,
    );
  }

  Widget _buildProfileOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildProfileOption(
            icon: Icons.person_outline,
            title: 'Personal Information',
            onTap: _navigateToPersonalInfo,
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses',
            onTap: _navigateToSavedAddresses,
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: _navigateToNotifications,
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.security,
            title: 'Privacy Policy',
            onTap: _showPrivacyPolicy,
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.logout,
            title: 'Logout',
            onTap: _logout,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 0,
      thickness: 0.5,
      color: AppColors.borderLight,
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        const Text(
          'Version 1.0.0',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textLightGray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2024 Thal-Care Diagnostic Services',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textLightGray.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
