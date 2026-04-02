import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';
import 'followers_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pauseNotifications = true;
  Map<String, dynamic>? _profile;
  bool _loading = true;

  User? get _user => AuthService.instance.currentUser;

  String get _displayName =>
      _profile?['displayName'] ??
      _user?.displayName ??
      _user?.email?.split('@').first ??
      'User';

  String get _email => _user?.email ?? _user?.phoneNumber ?? '';

  String get _bio => _profile?['bio'] ?? '';

  int get _followerCount =>
      (_profile?['followers'] as List?)?.length ?? 0;

  int get _followingCount =>
      (_profile?['following'] as List?)?.length ?? 0;

  String get _signInMethod {
    final user = _user;
    if (user == null) return '';
    for (final info in user.providerData) {
      if (info.providerId == 'google.com') return 'Google';
      if (info.providerId == 'phone') return 'Phone';
      if (info.providerId == 'password') return 'Email';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await FirestoreService.instance.getProfile();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
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
          style: AppTextStyles.headlineSmall
              .copyWith(color: context.h.textPrimary),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style:
              AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: context.h.textSecondary)),
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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return SafeArea(
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.yellow))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My profile',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          _CircleIconButton(
                            icon: Icons.notifications_none_rounded,
                            onTap: () => _showComingSoon('Notifications'),
                          ),
                          const SizedBox(width: 8),
                          _CircleIconButton(
                            icon: Icons.settings_outlined,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SettingsScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Profile card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 18,
                          offset: const Offset(0, 10),
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
                                    backgroundImage:
                                        NetworkImage(_user!.photoURL!),
                                    backgroundColor:
                                        AppColors.yellow.withValues(alpha: 0.2),
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
                                            ? _displayName[0].toUpperCase()
                                            : '?',
                                        style: AppTextStyles.displayLarge
                                            .copyWith(
                                          color: AppColors.yellow,
                                          fontWeight: FontWeight.w800,
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
                              style: AppTextStyles.headlineSmall.copyWith(
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
                        if (_signInMethod.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.yellow.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Signed in via $_signInMethod',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.yellow,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Follower / Following counts — tappable
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatItem(
                              value: '$_followerCount',
                              label: 'followers',
                              color: colors,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const FollowersScreen(initialTab: 0),
                                  ),
                                ).then((_) => _loadProfile());
                              },
                            ),
                            const SizedBox(width: 14),
                            Container(
                              width: 1,
                              height: 20,
                              color: colors.divider,
                            ),
                            const SizedBox(width: 14),
                            _StatItem(
                              value: '$_followingCount',
                              label: 'following',
                              color: colors,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const FollowersScreen(initialTab: 1),
                                  ),
                                ).then((_) => _loadProfile());
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Edit Profile button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              ).then((updated) {
                                if (updated == true) _loadProfile();
                              });
                            },
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: const Text('Edit Profile'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.yellow,
                              side: const BorderSide(color: AppColors.yellow),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settings section
                  Container(
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _SettingRow(
                          icon: Icons.notifications_paused_outlined,
                          title: 'Pause notifications',
                          trailing: Switch(
                            value: _pauseNotifications,
                            activeThumbColor: AppColors.yellow,
                            activeTrackColor:
                                AppColors.yellow.withValues(alpha: 0.4),
                            onChanged: (value) {
                              setState(() => _pauseNotifications = value);
                            },
                          ),
                        ),
                        _SettingRow(
                          icon: Icons.tune_rounded,
                          title: 'General settings',
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: colors.textSecondary,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: ThemeProvider.instance,
                          builder: (context, mode, _) {
                            return _SettingRow(
                              icon: Icons.dark_mode_outlined,
                              title: 'Dark mode',
                              trailing: Switch(
                                value: mode == ThemeMode.dark,
                                activeThumbColor: AppColors.yellow,
                                activeTrackColor:
                                    AppColors.yellow.withValues(alpha: 0.4),
                                onChanged: (_) =>
                                    ThemeProvider.instance.toggleTheme(),
                              ),
                            );
                          },
                        ),
                        _SettingRow(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: colors.textSecondary,
                          ),
                          onTap: () => _showComingSoon('Language'),
                        ),
                        _SettingRow(
                          icon: Icons.group_outlined,
                          title: 'My contact',
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: colors.textSecondary,
                          ),
                          onTap: () => _showComingSoon('My contact'),
                        ),
                        _SettingRow(
                          icon: Icons.help_outline_rounded,
                          title: 'FAQ',
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: colors.textSecondary,
                          ),
                          onTap: () => _showComingSoon('FAQ'),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                          child: OutlinedButton(
                            onPressed: _signOut,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              foregroundColor: const Color(0xFFF06A61),
                              side: BorderSide(color: colors.divider),
                            ),
                            child: const Text('Log out'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// =============================================================================
// Private widgets
// =============================================================================

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.h;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colors.menuIconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: colors.textPrimary),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });

  final String value;
  final String label;
  final HemisphereColors color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: color.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color.textCaption),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.divider)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: colors.textPrimary),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}