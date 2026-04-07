import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../colors/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../fonts/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../../services/auth_state.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import '../../Dashboard_path/Dashboard.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _emailController  = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService      = AuthService();
  bool _isLoading         = false;
  bool _emailTouched      = false;
  bool _passwordTouched   = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _emailTouched    = true;
      _passwordTouched = true;
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signIn(
        email:    _emailController.text.trim(),
        password: _passwordController.text,
      );

      // ✅ FIX 1: Populate AuthState FIRST — this is synchronous and instant.
      //           DashboardService.fetchAll() reads ApiConfig.authHeaders which
      //           checks AuthState.token before SharedPreferences, so the token
      //           is guaranteed to be available the moment the Dashboard loads,
      //           with no async race condition.
      AuthState.setToken(response.token, userName: response.user.fullName);

      // ✅ FIX 2: Persist to SharedPreferences for cold-start / page-refresh survival.
      //           (main() reads this back into AuthState before runApp on next launch)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.token);
      await prefs.setString('user_email', response.user.email);
      await prefs.setString('user_name',  response.user.fullName);

      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => DashboardScreen()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed in successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth =
                constraints.maxWidth > 480 ? 400 : constraints.maxWidth;
            return Center(
              child: SizedBox(
                width: maxWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(AppStrings.welcomeBack,
                            style: AppTextStyles.heading1),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.signInSubtitle,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.textMedium),
                        ),
                        const SizedBox(height: 40),

                        // Email field
                        CustomTextField(
                          label:       AppStrings.emailLabel,
                          hint:        AppStrings.emailHint,
                          controller:  _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: AppColors.textMedium, size: 20),
                          textInputAction: TextInputAction.next,
                          onChanged: (v) {
                            if (!_emailTouched) {
                              setState(() => _emailTouched = true);
                            }
                            _formKey.currentState?.validate();
                          },
                          validator: _emailTouched
                              ? (v) {
                                  if (v == null || v.isEmpty) {
                                    return AppStrings.fieldRequired;
                                  }
                                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                                      .hasMatch(v)) {
                                    return AppStrings.invalidEmail;
                                  }
                                  return null;
                                }
                              : null,
                        ),

                        const SizedBox(height: 20),

                        // Password field
                        CustomTextField(
                          label:      AppStrings.passwordLabel,
                          hint:       AppStrings.passwordHint,
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppColors.textMedium, size: 20),
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _handleSignIn,
                          onChanged: (v) {
                            if (!_passwordTouched) {
                              setState(() => _passwordTouched = true);
                            }
                            _formKey.currentState?.validate();
                          },
                          validator: _passwordTouched
                              ? (v) {
                                  if (v == null || v.isEmpty) {
                                    return AppStrings.fieldRequired;
                                  }
                                  if (v.length < 8) {
                                    return AppStrings.passwordTooShort;
                                  }
                                  return null;
                                }
                              : null,
                        ),

                        const SizedBox(height: 12),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen()),
                              );
                            },
                            child: Text(
                              AppStrings.forgotPassword,
                              style: AppTextStyles.body.copyWith(
                                color:      AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        PrimaryButton(
                          label:     AppStrings.signIn,
                          isLoading: _isLoading,
                          onPressed: _handleSignIn,
                        ),

                        const SizedBox(height: 32),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: AppStrings.dontHaveAccount,
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.textMedium),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const SignUpScreen()),
                                    ),
                                    child: Text(
                                      AppStrings.signUpLink,
                                      style: AppTextStyles.body.copyWith(
                                        color:      AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
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