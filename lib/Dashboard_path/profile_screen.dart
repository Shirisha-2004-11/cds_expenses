import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors/app_colors.dart';
import '../screens/auth/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName  = '';
  String _userEmail = '';
  bool   _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName  = prefs.getString('user_name')  ?? 'User';
      _userEmail = prefs.getString('user_email') ?? '';
      _isLoading = false;
    });
  }

  String get _initials {
    if (_userName.isEmpty) return 'U';
    final parts = _userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return _userName[0].toUpperCase();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log out',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Color(0xFF5A5A5A)),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF6B6B6B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B6B6B), fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out',
                style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF750909), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleEditProfile() async {
    final nameController  = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Color(0xFF5A5A5A)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B6B6B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B6B6B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              style: const TextStyle(fontFamily: 'Poppins'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B6B6B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save',
                style: TextStyle(fontFamily: 'Poppins', color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (saved == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name',  nameController.text.trim());
      await prefs.setString('user_email', emailController.text.trim());
      setState(() {
        _userName  = nameController.text.trim();
        _userEmail = emailController.text.trim();
      });
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
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF5A5A5A),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxWidth = constraints.maxWidth > 480 ? 420 : constraints.maxWidth;
                  return Center(
                    child: SizedBox(
                      width: maxWidth,
                      // Use Column so profile is at top and logout at bottom
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),

                                  // ── Profile card at the top ──────────────
                                  _ProfileCard(
                                    userName:  _userName,
                                    userEmail: _userEmail,
                                    initials:  _initials,
                                    onEditTap: _handleEditProfile,
                                  ),

                                  const SizedBox(height: 28),

                                  // ── Support section label ────────────────
                                  // const Text(
                                  //   'Support',
                                  //   style: TextStyle(
                                  //     fontFamily: 'Poppins',
                                  //     fontSize: 16,
                                  //     fontWeight: FontWeight.w600,
                                  //     color: Color(0xFF5A5A5A),
                                  //   ),
                                  // ),
                                  // const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),

                          // ── Logout button pinned at the bottom ───────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            child: GestureDetector(
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
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String initials;
  final VoidCallback onEditTap;

  const _ProfileCard({
    required this.userName,
    required this.userEmail,
    required this.initials,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
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

          const SizedBox(height: 14),

          // Name
          Text(
            userName,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5A5A5A),
            ),
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            userEmail,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B6B6B),
            ),
          ),

          const SizedBox(height: 18),

          // Edit profile button
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(15.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 15),
                  SizedBox(width: 6),
                  Text(
                    'Edit profile',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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
