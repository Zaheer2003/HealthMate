import 'package:flutter/material.dart';
import 'package:student_records_app/features/auth/services/auth_service.dart';
import 'package:student_records_app/features/auth/widgets/auth_button.dart';
import 'package:student_records_app/features/auth/widgets/auth_text_field.dart';
import 'package:student_records_app/features/auth/views/login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _pageController = PageController();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSendCodePage(),
          _buildVerifyCodePage(),
          _buildResetPasswordPage(),
        ],
      ),
    );
  }

  // Page 1: Send Code
  Widget _buildSendCodePage() {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Enter your email to receive a password reset code.'),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: emailController,
                  labelText: 'Email',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AuthButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true);
                      final success = await _authService.sendPasswordResetCode(emailController.text);
                      setState(() => isLoading = false);
                      if (success) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email not found')));
                      }
                    }
                  },
                  text: 'Send Code',
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Page 2: Verify Code
  Widget _buildVerifyCodePage() {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Enter the 6-digit code sent to your email.'),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: codeController,
                  labelText: 'Verification Code',
                  icon: Icons.pin,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter the code';
                    if (value.length != 6) return 'Code must be 6 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AuthButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true);
                      final success = await _authService.verifyCode(codeController.text);
                      setState(() => isLoading = false);
                      if (success) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid code')));
                      }
                    }
                  },
                  text: 'Verify',
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Page 3: Reset Password
  Widget _buildResetPasswordPage() {
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Enter your new password.'),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: passwordController,
                  labelText: 'New Password',
                  obscureText: true,
                  icon: Icons.lock,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a new password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: confirmPasswordController,
                  labelText: 'Confirm New Password',
                  obscureText: true,
                  icon: Icons.lock,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AuthButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true);
                      final success = await _authService.resetPassword(passwordController.text);
                      setState(() => isLoading = false);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successful!')));
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to reset password')));
                      }
                    }
                  },
                  text: 'Reset Password',
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
