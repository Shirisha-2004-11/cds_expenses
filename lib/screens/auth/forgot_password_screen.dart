import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../colors/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import 'sign_in_screen.dart';

enum _ForgotStep { email, otp, resetPassword, success }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();

  _ForgotStep _currentStep = _ForgotStep.email;
  bool _isLoading = false;

  // Step 1 – Email
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailDirty = false;

  // Step 2 – OTP
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());
  String get _otpValue =>
      _otpControllers.map((c) => c.text).join();

  // Step 3 – Reset Password
  final _resetFormKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _goTo(_ForgotStep step) {
    if (step == _ForgotStep.email) _emailDirty = false;
    setState(() => _currentStep = step);
  }

  // ─── Step handlers ──────────────────────────────────────────────────────────

  Future<void> _handleSendEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.forgotPassword(email: _emailController.text.trim());
      _goTo(_ForgotStep.otp);
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // OTP is not verified separately — it is validated by the backend
  // during resetPassword. Here we just collect it and move forward.
  void _handleVerifyOtp() {
    if (_otpValue.length < 6) {
      _showError('Please enter the complete 6-digit OTP.');
      return;
    }
    _goTo(_ForgotStep.resetPassword);
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isLoading = true);
    try {
      await _authService.forgotPassword(email: _emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully.')),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(
        email: _emailController.text.trim(),
        otp: _otpValue,
        password: _newPasswordController.text,
      );
      _goTo(_ForgotStep.success);
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Navigation ─────────────────────────────────────────────────────────────

  void _handleBack() {
    switch (_currentStep) {
      case _ForgotStep.email:
        Navigator.pop(context);
      case _ForgotStep.otp:
        _goTo(_ForgotStep.email);
      case _ForgotStep.resetPassword:
        _goTo(_ForgotStep.otp);
      case _ForgotStep.success:
        break;
    }
  }

  bool get _showBackButton => _currentStep != _ForgotStep.success;

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _showBackButton
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Color(0xFF3B3B3B), size: 20),
                onPressed: _handleBack,
              ),
            )
          : null,
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_currentStep),
                      child: _buildCurrentStep(),
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

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case _ForgotStep.email:
        return _buildEmailStep();
      case _ForgotStep.otp:
        return _buildOtpStep();
      case _ForgotStep.resetPassword:
        return _buildResetPasswordStep();
      case _ForgotStep.success:
        return _buildSuccessStep();
    }
  }

  // ─── Step 1: Email ──────────────────────────────────────────────────────────

  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Forgot Password?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B3B3B),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Enter your registered email address. We'll send you an OTP to verify your identity.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7C7C7C),
            ),
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onEditingComplete: _handleSendEmail,
            autovalidateMode: _emailDirty
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            onChanged: (_) {
              if (!_emailDirty) setState(() => _emailDirty = true);
            },
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF3B3B3B),
            ),
            decoration: InputDecoration(
              labelText: AppStrings.emailLabel,
              hintText: AppStrings.emailHint,
              prefixIcon: const Icon(Icons.email_outlined,
                  color: AppColors.textMedium, size: 20),
              filled: true,
              fillColor: Colors.white,
              labelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textMedium,
              ),
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textMedium,
              ),
              errorStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide:
                    const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide:
                    const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 2),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return AppStrings.fieldRequired;
              }
              final trimmed = v.trim();
              if (trimmed.length > 254) {
                return 'Email address is too long.';
              }
              if (trimmed.contains(' ')) {
                return 'Email must not contain spaces.';
              }
              if (!RegExp(
                      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(trimmed)) {
                return AppStrings.invalidEmail;
              }
              if (trimmed.startsWith('.') ||
                  trimmed.startsWith('@') ||
                  trimmed.contains('..')) {
                return AppStrings.invalidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Send OTP',
            isLoading: _isLoading,
            onPressed: _handleSendEmail,
          ),
          const SizedBox(height: 24),
          _loginLink(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Step 2: OTP ────────────────────────────────────────────────────────────

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Enter OTP',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3B3B3B),
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7C7C7C),
            ),
            children: [
              const TextSpan(text: 'We sent a 6-digit OTP to\n'),
              TextSpan(
                text: _emailController.text.trim(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B3B3B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildOtpFields(),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Verify OTP',
          isLoading: _isLoading,
          onPressed: _handleVerifyOtp,
        ),
        const SizedBox(height: 20),
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Didn't receive the code?  ",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7C7C7C),
                  ),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _handleResendOtp,
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 46,
          height: 54,
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B3B3B),
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _otpFocusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _otpFocusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  // ─── Step 3: Reset Password ─────────────────────────────────────────────────

  Widget _buildResetPasswordStep() {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Reset Password',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B3B3B),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create a new password. Make sure it\'s strong and easy to remember.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7C7C7C),
            ),
          ),
          const SizedBox(height: 40),
          CustomTextField(
            label: 'New Password',
            hint: 'Enter new password',
            controller: _newPasswordController,
            isPassword: true,
            prefixIcon: const Icon(Icons.lock_outline,
                color: AppColors.textMedium, size: 20),
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return AppStrings.fieldRequired;
              }
              if (v.length < 8) {
                return 'Password must be at least 8 characters.';
              }
              if (v.length > 64) {
                return 'Password must not exceed 64 characters.';
              }
              if (!RegExp(r'[A-Z]').hasMatch(v)) {
                return 'Must contain at least one uppercase letter.';
              }
              if (!RegExp(r'[a-z]').hasMatch(v)) {
                return 'Must contain at least one lowercase letter.';
              }
              if (!RegExp(r'[0-9]').hasMatch(v)) {
                return 'Must contain at least one number.';
              }
              if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\+=/\\]').hasMatch(v)) {
                return 'Must contain at least one special character.';
              }
              if (v.contains(' ')) {
                return 'Password must not contain spaces.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Confirm Password',
            hint: 'Re-enter new password',
            controller: _confirmPasswordController,
            isPassword: true,
            prefixIcon: const Icon(Icons.lock_outline,
                color: AppColors.textMedium, size: 20),
            textInputAction: TextInputAction.done,
            onEditingComplete: _handleResetPassword,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return AppStrings.fieldRequired;
              }
              if (v != _newPasswordController.text) {
                return 'Passwords do not match.';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Reset Password',
            isLoading: _isLoading,
            onPressed: _handleResetPassword,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Step 4: Success ────────────────────────────────────────────────────────

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.primary,
            size: 48,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Password Reset!',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3B3B3B),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your password has been reset successfully.\nYou can now log in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7C7C7C),
          ),
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          label: 'Back to Login',
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── Shared Widgets ─────────────────────────────────────────────────────────

  Widget _loginLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'You remember your password?  ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7C7C7C),
              ),
            ),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}