import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/providers/theme_provider.dart';
import 'package:chatapp/widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                UserAvatar(
                  user: user,
                  radius: 50,
                  showOnlineStatus: false,
                ),
                const SizedBox(height: 16),
                Text(
                  user.username,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit Profile coming soon')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side:
                        BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Settings Sections
          _buildSectionHeader(context, 'PREFERENCES'),
          _buildSettingItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(),
              activeColor: colorScheme.primary,
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notification settings coming soon')),
              );
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'ACCOUNT'),
          _buildSettingItem(
            context,
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy settings coming soon')),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help section coming soon')),
              );
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'SESSION'),

          Container(
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(0),
            child: ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text(
                'Log Out',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _showLogoutDialog(context, authProvider),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ??
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
              context.go('/login');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
