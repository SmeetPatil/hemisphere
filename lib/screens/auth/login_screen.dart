import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../home_screen.dart';
import 'signup_screen.dart';
import 'phone_auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;

  static const Color backgroundDark = Color(0xFF0B101A);
  static const Color accentYellow = Color(0xFFFFD700);
  static const Color cardDark = Color(0xFF161F30);
  static const Color textWhite = Color(0xFFFCFCFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF0F172A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
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
        return; // user cancelled
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(AuthService.friendlyError(e));
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      if (!mounted) return;
      _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Satoshi')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(color: textWhite, fontFamily: 'Satoshi', fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.8), fontFamily: 'Satoshi'),
              prefixIcon: Icon(icon, color: textMuted, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: textWhite.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : null,
              border: InputBorder.none,
              errorStyle: const TextStyle(height: 0.8),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          // Top Image Area (Extended slightly to 55% so glass at 45% overlaps it gracefully)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/loginpage.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              // Optional: slightly darken the bottom of the image behind the glass
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      backgroundDark.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // App Name Heading
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'HemiSphere',
                style: TextStyle(
                  fontFamily: 'Clash Display',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: accentYellow,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),

          // Bottom 50% section -> Container starts at 48% overlapping the image
          Positioned(
            top: size.height * 0.48,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardDark.withValues(alpha: 0.45), // Deep glassmorphism
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    border: Border(
                      top: BorderSide(color: accentYellow.withValues(alpha: 0.6), width: 1.5), // Yellow tinted glass border trim
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(), // Prevent scrolling / bouncy edge
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Build a Better Community',
                            style: TextStyle(
                              fontFamily: 'Clash Display',
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: textWhite,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Log in to connect and engage.',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 15,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildGlassInput(
                            controller: _emailController,
                            hint: 'Email Address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email' : null,
                          ),
                          const SizedBox(height: 8),
                          _buildGlassInput(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentYellow,
                                foregroundColor: backgroundDark,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _loading ? null : _signInEmail,
                              child: _loading
                                  ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(color: backgroundDark, strokeWidth: 3),
                                    )
                                  : const Text(
                                      'Log In',
                                      style: TextStyle(
                                        fontFamily: 'Clash Display',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(child: Divider(color: textWhite.withValues(alpha: 0.1), thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Or continue with',
                                  style: TextStyle(fontFamily: 'Satoshi', color: textMuted, fontSize: 13),
                                ),
                              ),
                              Expanded(child: Divider(color: textWhite.withValues(alpha: 0.1), thickness: 1)),
                            ],
                          ),
                          
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildSocialButton(
                                  icon: Icons.g_mobiledata_rounded,
                                  label: 'Google',
                                  onTap: _loading ? null : _signInGoogle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSocialButton(
                                  icon: Icons.phone_iphone_rounded,
                                  label: 'Phone',
                                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PhoneAuthScreen())),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SignUpScreen())),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              ),
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontFamily: 'Satoshi', color: textMuted, fontSize: 14),
                                  children: [
                                    TextSpan(text: "Don't have an account? "),
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(
                                        fontFamily: 'Clash Display',
                                        color: accentYellow,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
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

  Widget _buildSocialButton({required IconData icon, required String label, required VoidCallback? onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textWhite, size: 22),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    color: textWhite,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
