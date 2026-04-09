import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';
import 'emission_logger_screen.dart';
import 'my_activity_list.dart';
import '../../widgets/tab_entry_animator.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  int _refreshCounter = 0;

  User? get _user => AuthService.instance.currentUser;

  String get _displayName =>
      _profile?['displayName'] ??
      _user?.displayName ??
      _user?.email?.split('@').first ??
      'User';

  String get _email => _user?.email ?? _user?.phoneNumber ?? '';

  String get _bio => _profile?['bio'] ?? '';

  String get _joinedDate {
    DateTime? date;
    final joinedAt = _profile?['joinedAt'];

    if (joinedAt != null) {
      try {
        date = (joinedAt as dynamic).toDate() as DateTime;
      } catch (_) {
        if (joinedAt is String) date = DateTime.tryParse(joinedAt);
      }
    }

    date ??= _user?.metadata.creationTime;

    if (date == null) return '';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    HomeScreen.currentTabNotifier.addListener(_handleBottomTabSelection);
    _loadProfile();
  }

  void _handleBottomTabSelection() {
    if (HomeScreen.currentTabNotifier.value == 4) {
      _loadProfile(); // refresh when switching back to this tab
    }
  }

  @override
  void dispose() {
    HomeScreen.currentTabNotifier.removeListener(_handleBottomTabSelection);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await FirestoreService.instance.getProfile();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
      _refreshCounter++;
    });
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.h.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: AppTextStyles.headlineSmall.copyWith(
            color: context.h.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.h.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.h.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -20,
                top: -60,
                child: SizedBox(
                  width: 275,
                  height: 145,
                  child: TabEntryAnimator(
                    tabIndex: 4,
                    delayMs: 50,
                    child: SvgPicture.asset(
                      'assets/images/profile.svg',
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabEntryAnimator(
                            tabIndex: 4,
                            child: Text(
                              'Profile',
                              style: AppTextStyles.displayLarge.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          TabEntryAnimator(
                            tabIndex: 4,
                            delayMs: 40,
                            child: Text(
                              'Manage your account and activity',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.yellow),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile card
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                24,
                                16,
                                16,
                              ),
                              decoration: BoxDecoration(
                                color: colors.card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.black,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.black,
                                    blurRadius: 0,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Avatar
                                  Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      _user?.photoURL != null
                                          ? CircleAvatar(
                                              radius: 44,
                                              backgroundImage: NetworkImage(
                                                _user!.photoURL!,
                                              ),
                                              backgroundColor: AppColors.yellow
                                                  .withValues(alpha: 0.2),
                                            )
                                          : Container(
                                              width: 88,
                                              height: 88,
                                              decoration: BoxDecoration(
                                                color: AppColors.yellow
                                                    .withValues(alpha: 0.2),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.yellow,
                                                  width: 2.5,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _displayName.isNotEmpty
                                                      ? _displayName[0]
                                                            .toUpperCase()
                                                      : '?',
                                                  style: AppTextStyles
                                                      .displayLarge
                                                      .copyWith(
                                                        color: AppColors.yellow,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _displayName,
                                        style: AppTextStyles.headlineSmall
                                            .copyWith(
                                              color: colors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      if (_user?.emailVerified == true) ...[
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: AppColors.yellow,
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _email,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  if (_bio.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      _bio,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: colors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                  if (_joinedDate.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.yellow,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.black,
                                          width: 1.5,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: AppColors.black,
                                            blurRadius: 0,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Member since $_joinedDate',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),

                                  // Edit Profile button
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const EditProfileScreen(),
                                        ),
                                      ).then((updated) {
                                        if (updated == true) _loadProfile();
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.yellow,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.black,
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: AppColors.black,
                                            blurRadius: 0,
                                            offset: Offset(4, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.edit_rounded,
                                            color: AppColors.black,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Edit Profile',
                                            style: AppTextStyles.buttonMedium
                                                .copyWith(
                                                  color: AppColors.black,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Log out button
                                  GestureDetector(
                                    onTap: _signOut,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.black,
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: AppColors.black,
                                            blurRadius: 0,
                                            offset: Offset(4, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Log out',
                                          style: AppTextStyles.buttonMedium
                                              .copyWith(
                                                color: const Color(0xFFF06A61),
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.settings_rounded,
                                  color: AppColors.black,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  ).then((_) => _loadProfile());
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Log Emissions Animated Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmissionLoggerScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 100, // Taller button
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.black,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.black,
                                  blurRadius: 0,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Positioned.fill(
                                  child: _GasParticlesAnimation(
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.eco_rounded,
                                      color: AppColors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Log Emissions',
                                      style: AppTextStyles.displayMedium
                                          .copyWith(
                                            color: AppColors.white,
                                            fontSize: 24,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // My Activity Section
                        Text(
                          'My Posts & Activity',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MyActivityList(refreshTrigger: _refreshCounter),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _GasParticlesAnimation extends StatefulWidget {
  final Color color;
  const _GasParticlesAnimation({required this.color});

  @override
  State<_GasParticlesAnimation> createState() => _GasParticlesAnimationState();
}

class _GasParticlesAnimationState extends State<_GasParticlesAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_GasParticle> _particles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 20; i++) {
      _particles.add(
        _GasParticle(
          x: _rnd.nextDouble(),
          y: _rnd.nextDouble(),
          speedX: (_rnd.nextDouble() - 0.5) * 0.005,
          speedY:
              (_rnd.nextDouble() * 0.005) +
              0.002, // Always move slightly upwards
          radius: _rnd.nextDouble() * 15 + 10,
        ),
      );
    }
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..addListener(() {
            for (var p in _particles) {
              p.x += p.speedX;
              p.y -= p.speedY; // move up
              if (p.x < 0 || p.x > 1) p.speedX *= -1;
              if (p.y < -0.2) {
                p.y = 1.2; // reset from bottom
                p.x = _rnd.nextDouble();
              }
            }
          })
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _GasParticlePainter(
            particles: _particles,
            color: widget.color.withValues(alpha: 0.15),
          ),
        );
      },
    );
  }
}

class _GasParticle {
  double x, y, speedX, speedY, radius;
  _GasParticle({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.radius,
  });
}

class _GasParticlePainter extends CustomPainter {
  final List<_GasParticle> particles;
  final Color color;

  _GasParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    for (var p in particles) {
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GasParticlePainter oldDelegate) => true;
}
