import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../home_screen.dart';
import 'login_screen.dart';
import 'phone_auth_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Auth actions
  // ---------------------------------------------------------------------------

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Set display name
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        await AuthService.instance.updateDisplayName(name);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(AuthService.friendlyError(e));
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInGoogle() async {
    setState(() => _loading = true);
    try {
      final result = await AuthService.instance.signInWithGoogle();
      if (result == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(AuthService.friendlyError(e));
    } catch (e) {
      if (!mounted) return;
      _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colors = context.h;

    return Scaffold(
      backgroundColor: isDark ? colors.background : const Color(0xFFECE8D8),
      body: Stack(
        children: [
          // Yellow arc header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 258,
              decoration: const BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(128),
                  bottomRight: Radius.circular(128),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                    decoration: BoxDecoration(
                      color: isDark ? colors.card : const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(34),
                      boxShadow: [
                        BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 26,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BrandMark(isDark: isDark),
                          const SizedBox(height: 18),
                          Text(
                            'Create Account',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color:
                                  isDark ? AppColors.white : AppColors.grey900,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Join the Hemisphere community',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  isDark ? AppColors.grey400 : AppColors.grey600,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Name
                          _buildField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            isDark: isDark,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email
                          _buildField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.mail_outline,
                            isDark: isDark,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter your email';
                              }
                              if (!v.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _buildField(
                            controller: _passwordController,
                            label: 'Create Password',
                            icon: Icons.lock_outline,
                            isDark: isDark,
                            obscureText: _obscurePassword,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter a password';
                              }
                              if (v.length < 6) {
                                return 'At least 6 characters';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: isDark
                                  ? AppColors.grey400
                                  : AppColors.grey600,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sign Up button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.yellow,
                                foregroundColor: AppColors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _loading ? null : _signUp,
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.black,
                                      ),
                                    )
                                  : Text(
                                      'Sign Up',
                                      style:
                                          AppTextStyles.buttonMedium.copyWith(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppColors.grey700
                                      : AppColors.grey300,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or continue with',
                                  style: AppTextStyles.caption.copyWith(
                                    color: isDark
                                        ? AppColors.grey400
                                        : const Color(0xFF9D9D9D),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppColors.grey700
                                      : AppColors.grey300,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Social buttons
                          Row(
                            children: [
                              Expanded(
                                child: _SocialButton(
                                  icon: Icons.g_mobiledata_rounded,
                                  label: 'Google',
                                  color: Colors.redAccent,
                                  isDark: isDark,
                                  onTap: _loading ? null : _signInGoogle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SocialButton(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  color: AppColors.green,
                                  isDark: isDark,
                                  onTap: _loading
                                      ? null
                                      : () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const PhoneAuthScreen(),
                                            ),
                                          );
                                        },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Terms
                          Center(
                            child: Text(
                              'By signing up, you agree to our\nTerms & Privacy Policy',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(
                                color: isDark
                                    ? AppColors.grey400
                                    : const Color(0xFF9D9D9D),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login link
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.grey300
                                        : AppColors.grey600,
                                  ),
                                  children: [
                                    const TextSpan(
                                        text: 'Already have an account? '),
                                    TextSpan(
                                      text: 'Login',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.yellow
                                            : AppColors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isDark ? AppColors.white : AppColors.grey900,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.grey400 : AppColors.grey600,
        ),
        prefixIcon: Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.grey400 : AppColors.grey600,
        ),
        suffixIcon: suffixIcon,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.grey700 : AppColors.grey300,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.grey700 : AppColors.grey300,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.yellow, width: 2),
        ),
      ),
    );
  }
}

// =============================================================================
// Private widgets
// =============================================================================

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 8,
            child: Transform.rotate(
              angle: 0.14,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: AppColors.yellow.withValues(alpha: 0.7),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 4,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isDark ? AppColors.white : AppColors.black,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.grey900 : AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.grey700 : AppColors.grey300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.white : AppColors.grey900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}