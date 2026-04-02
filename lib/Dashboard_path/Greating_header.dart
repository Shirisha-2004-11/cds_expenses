import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ── Centralised theme tokens ─────────────────────────────────────────────────
// ignore: unused_import
import '../colors/dashboard_colors.dart';
// ignore: unused_import
import '../fonts/dashboard_text_styles.dart';
// ignore: unused_import
import '../widgets/common/dashboard_icon_box.dart';

class GreetingHeader extends StatefulWidget {
  const GreetingHeader({super.key});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<GreetingHeader> {
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Load name from local storage
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    setState(() {
      _userName = name;
      _isLoading = false;
    });

    // If no name saved yet, ask the user
    if (name.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNameDialog();
      });
    }
  }

  // Save name to local storage
  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    setState(() => _userName = name);
  }

  // Dialog to ask for name
  void _showNameDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Welcome! 👋',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What should we call you?',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                filled: true,
                fillColor: const Color(0xFFF7F8FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  _saveUserName(name);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Let\'s go!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 60);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Avatar — tap to change name
          GestureDetector(
            onTap: _showNameDialog,
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFE0E0E0),
              child: Icon(Icons.person, color: Colors.grey, size: 22),
            ),
          ),
          const SizedBox(width: 12),

          // Greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName.isEmpty
                      ? '${_getGreeting()} 👋'
                      : '${_getGreeting()}, $_userName 👋',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Text(
                  "Here's your spending overview",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Notification Bell
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: Color(0xFF1A1A2E), size: 20),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}