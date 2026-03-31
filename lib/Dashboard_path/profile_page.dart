import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../screens/auth/welcome_screen.dart';
// ── Centralised theme tokens ─────────────────────────────────────────────────
// ignore: unused_import
import '../../theme/dashboard_colors.dart';
// ignore: unused_import
import '../../theme/dashboard_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Real user data loaded from SharedPreferences (saved during sign in/sign up)
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load real user data saved at login
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
      _userEmail = prefs.getString('user_email') ?? '';
      _isLoading = false;
    });
  }

  // Get initials from name for avatar fallback
  String get _initials {
    if (_userName.isEmpty) return 'U';
    final parts = _userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _userName[0].toUpperCase();
  }

  // Logout with confirmation dialog
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log out',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A5A5A),
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF6B6B6B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF6B6B6B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log out',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF750909),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Clear all saved user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        // Navigate back to welcome screen and clear all routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5A5A5A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth = constraints.maxWidth > 480 ? 420 : constraints.maxWidth;
                return Center(
                  child: SizedBox(
                    width: maxWidth,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Profile card ─────────────────────────────
                          _ProfileCard(
                            userName: _userName,
                            userEmail: _userEmail,
                            initials: _initials,
                          ),

                          const SizedBox(height: 24),

                          // ── Settings section ──────────────────────────
                          _SectionLabel(label: 'Settings'),
                          const SizedBox(height: 10),
                          _SettingsCard(
                            items: [
                              _MenuItem(
                                icon: _buildCircleIcon(Icons.person_outline),
                                title: 'Account',
                                subtitle: 'Personal info',
                                onTap: () {
                                  // TODO: Navigate to Account screen
                                },
                              ),
                              _MenuItem(
                                icon: _buildCurrencyIcon(),
                                title: 'Currency',
                                subtitle: 'Current : INR ₹',
                                subtitleHighlight: 'INR ₹',
                                onTap: () {
                                  // TODO: Navigate to Currency screen
                                },
                              ),
                              _MenuItem(
                                icon: _buildCategoriesIcon(),
                                title: 'Categories',
                                subtitle: 'Manage expense categories',
                                onTap: () {
                                  // TODO: Navigate to Categories screen
                                },
                                showDivider: false,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── App features section ──────────────────────
                          _SectionLabel(label: 'App features'),
                          const SizedBox(height: 10),
                          _SettingsCard(
                            items: [
                              _MenuItem(
                                icon: _buildCircleIcon(Icons.document_scanner_outlined),
                                title: 'Smart scan',
                                subtitle: 'Scan receipts to auto-fill info',
                                onTap: () {
                                  // TODO: Navigate to Smart scan screen
                                },
                              ),
                              _MenuItem(
                                icon: _buildCurrencyIcon(),
                                title: 'Export data',
                                subtitle: 'Download expense reports',
                                onTap: () {
                                  // TODO: Navigate to Export data screen
                                },
                                showDivider: false,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Support section ───────────────────────────
                          _SectionLabel(label: 'Support'),
                          const SizedBox(height: 10),

                          // ── Log out button ────────────────────────────
                          GestureDetector(
                            onTap: _handleLogout,
                            child: Container(
                              width: double.infinity,
                              height: 53,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFEED4D6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26.5),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Log out',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF750909),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ── Icon builders ─────────────────────────────────────────
  Widget _buildCircleIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: const ShapeDecoration(
        color: Color(0x00D9D9D9),
        shape: OvalBorder(
          side: BorderSide(width: 2, color: AppColors.primary),
        ),
      ),
      child: Icon(icon, color: AppColors.primary, size: 16),
    );
  }

  Widget _buildCurrencyIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0x331D8F86),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary, width: 0.8),
      ),
      child: const Center(
        child: Text(
          '₹',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesIcon() {
    return SizedBox(
      width: 32,
      height: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const ShapeDecoration(
                    color: Color(0x00D9D9D9),
                    shape: OvalBorder(
                      side: BorderSide(width: 1, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 14,
                  height: 1,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Profile card widget ───────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String initials;

  const _ProfileCard({
    required this.userName,
    required this.userEmail,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          // Avatar — shows initials (no image needed)
          // Replace with Image.asset/network when profile photo is available
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Real user name from sign in / sign up
          Text(
            userName,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5A5A5A),
            ),
          ),

          const SizedBox(height: 4),

          // Real user email from sign in / sign up
          Text(
            userEmail,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B6B6B),
            ),
          ),

          const SizedBox(height: 14),

          // Edit profile button
          GestureDetector(
            onTap: () {
              // TODO: Navigate to Edit Profile screen
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(15.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Edit profile',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFF3F3F3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF5A5A5A),
      ),
    );
  }
}

// ── Settings card with list of menu items ─────────────────────
class _SettingsCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) => item).toList(),
      ),
    );
  }
}

// ── Single menu item row ──────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final String? subtitleHighlight;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleHighlight,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon
                icon,
                const SizedBox(width: 12),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A5A5A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      subtitleHighlight != null
                          ? _buildHighlightedSubtitle()
                          : Text(
                              subtitle,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B6B6B),
                              ),
                            ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6B6B6B),
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Divider between items
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 0.5, color: Color(0xFFBABABA)),
          ),
      ],
    );
  }

  Widget _buildHighlightedSubtitle() {
    // Shows "Current : " in gray and "INR ₹" in teal
    final parts = subtitle.split(subtitleHighlight!);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: parts[0],
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B6B6B),
            ),
          ),
          TextSpan(
            text: subtitleHighlight,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
