import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colors = context.h;

    return Scaffold(
      backgroundColor: isDark ? colors.background : const Color(0xFFECE8D8),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(130),
                  bottomRight: Radius.circular(130),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BrandMark(isDark: isDark),
                        const SizedBox(height: 18),
                        Text(
                          'Login',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: isDark ? AppColors.white : AppColors.grey900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _UnderlineField(
                          label: 'Email',
                          icon: Icons.mail_outline,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _UnderlineField(
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Login',
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'By signing in, you agree to our\nTerms & Privacy Policy',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                  ? AppColors.grey400
                                  : const Color(0xFF9D9D9D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'or',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                  ? AppColors.grey400
                                  : const Color(0xFF9D9D9D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialButton(
                              text: 'G',
                              color: Colors.redAccent,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 14),
                            _SocialButton(
                              text: 'f',
                              color: const Color(0xFF4267B2),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 14),
                            _SocialButton(
                              text: 'X',
                              color: const Color(0xFF1DA1F2),
                              isDark: isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodySmall.copyWith(
                                  color:
                                      isDark ? colors.textSecondary : AppColors.grey600,
                                ),
                                children: [
                                  const TextSpan(text: 'Don\'t have an account? '),
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color:
                                          isDark ? AppColors.yellow : AppColors.black,
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
        ],
      ),
    );
  }
}

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

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
    required this.label,
    required this.icon,
    required this.isDark,
    this.obscureText = false,
  });

  final String label;
  final IconData icon;
  final bool isDark;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.text,
    required this.color,
    required this.isDark,
  });

  final String text;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.grey900 : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.labelLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}