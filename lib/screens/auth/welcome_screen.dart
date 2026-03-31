import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/outlined_primary_button.dart';
import '../../widgets/common/microsoft_button.dart';
import '../../widgets/common/or_divider.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'microsoft_auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _microsoftLoading = false;

  Future<void> _handleMicrosoftLogin() async {
    setState(() => _microsoftLoading = true);
    try {
      await MicrosoftAuthService.signIn(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.microsoftLoginFailed),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _microsoftLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth =
                constraints.maxWidth > 480 ? 400 : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: maxWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // ── Logo + Image area ───────────────────────────
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40), // ← moves logo down
                            _CovalenseLogo(),
                            const SizedBox(height: 25),

                            // 🔽 NEW IMAGE ADDED (from Figma)
                            Flexible(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Buttons area ─────────────────────────────────
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedPrimaryButton(
                              label: AppStrings.signIn,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignInScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 26),

                            PrimaryButton(
                              label: AppStrings.signUp,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            const OrDivider(),
                            const SizedBox(height: 24),

                            MicrosoftButton(
                              isLoading: _microsoftLoading,
                              onPressed: _handleMicrosoftLogin,
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Logo widget ─────────────────────────────────────────────
class _CovalenseLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/covalense_logo.svg',
      height: 100,
    );
  }
}