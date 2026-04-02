import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../colors/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../fonts/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import 'sign_in_screen.dart';
import '../../Dashboard_path/Dashboard.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final _authService = AuthService();
  bool _isLoading = false;

  bool _fullNameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;

  @override
  void initState() {
    super.initState();
    _fullNameFocusNode.addListener(() {
      if (!_fullNameFocusNode.hasFocus && _fullNameController.text.isNotEmpty) {
        setState(() => _fullNameTouched = true);
        _formKey.currentState?.validate();
      }
    });
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus && _emailController.text.isNotEmpty) {
        setState(() => _emailTouched = true);
        _formKey.currentState?.validate();
      }
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus && _passwordController.text.isNotEmpty) {
        setState(() => _passwordTouched = true);
        _formKey.currentState?.validate();
      }
    });
    _confirmPasswordFocusNode.addListener(() {
      if (!_confirmPasswordFocusNode.hasFocus && _confirmPasswordController.text.isNotEmpty) {
        setState(() => _confirmPasswordTouched = true);
        _formKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _fullNameTouched = true;
      _emailTouched = true;
      _passwordTouched = true;
      _confirmPasswordTouched = true;
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signUp(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.token);
      await prefs.setString('user_email', response.user.email);
      await prefs.setString('user_name', response.user.fullName);

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
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
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth > 480 ? 400 : constraints.maxWidth;
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
                        Text(AppStrings.createAccount, style: AppTextStyles.heading1),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.signUpSubtitle,
                          style: AppTextStyles.body.copyWith(color: AppColors.textMedium),
                        ),
                        const SizedBox(height: 36),

                        // Full Name
                        CustomTextField(
                          label: AppStrings.fullNameLabel,
                          hint: AppStrings.fullNameHint,
                          controller: _fullNameController,
                          // focusNode: _fullNameFocusNode,
                          keyboardType: TextInputType.name,
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMedium, size: 20),
                          validator: _fullNameTouched
                              ? (v) => (v == null || v.isEmpty) ? AppStrings.fieldRequired : null
                              : null,
                        ),

                        const SizedBox(height: 20),

                        // Email
                        CustomTextField(
                          label: AppStrings.emailLabel,
                          hint: AppStrings.emailHint,
                          controller: _emailController,
                          // focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textMedium, size: 20),
                          validator: _emailTouched
                              ? (v) {
                                  if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) {
                                    return AppStrings.invalidEmail;
                                  }
                                  return null;
                                }
                              : null,
                        ),

                        const SizedBox(height: 20),

                        // Password
                        CustomTextField(
                          label: AppStrings.passwordLabel,
                          hint: AppStrings.passwordHint,
                          controller: _passwordController,
                          // focusNode: _passwordFocusNode,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMedium, size: 20),
                          validator: _passwordTouched
                              ? (v) {
                                  if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                                  if (v.length < 8) return AppStrings.passwordTooShort;
                                  return null;
                                }
                              : null,
                        ),

                        const SizedBox(height: 20),

                        // Confirm Password
                        CustomTextField(
                          label: AppStrings.confirmPasswordLabel,
                          hint: AppStrings.confirmPasswordHint,
                          controller: _confirmPasswordController,
                          // focusNode: _confirmPasswordFocusNode,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMedium, size: 20),
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _handleSignUp,
                          validator: _confirmPasswordTouched
                              ? (v) {
                                  if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                                  if (v != _passwordController.text) return AppStrings.passwordsDoNotMatch;
                                  return null;
                                }
                              : null,
                        ),

                        const SizedBox(height: 32),

                        PrimaryButton(
                          label: AppStrings.signUp,
                          isLoading: _isLoading,
                          onPressed: _handleSignUp,
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: AppStrings.alreadyHaveAccount,
                              style: AppTextStyles.body.copyWith(color: AppColors.textMedium),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                                    ),
                                    child: Text(
                                      AppStrings.signInLink,
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.primary,
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