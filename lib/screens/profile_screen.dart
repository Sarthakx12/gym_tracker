import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/workout_provider.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pressable.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final email = SupabaseService.userEmail;
    final isLoggedIn = SupabaseService.isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 24),

            // Header
            const Text(
              'Profile',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),

            const SizedBox(height: 28),

            // Account card
            _Card(
              child: isLoggedIn
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.elevated,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  size: 22, color: AppColors.textSub),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Signed in',
                                    style: TextStyle(
                                      color: AppColors.textSub,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email ?? '',
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.elevated,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(Icons.person_outline_rounded,
                              size: 22, color: AppColors.textTert),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Not signed in',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Local data only',
                                style: TextStyle(
                                  color: AppColors.textTert,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // Sync card
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_sync_rounded,
                          size: 20, color: AppColors.textSub),
                      const SizedBox(width: 12),
                      const Text(
                        'Cloud Sync',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (provider.isSyncing)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textSub,
                          ),
                        )
                      else if (!isLoggedIn)
                        const Icon(Icons.cloud_off_rounded,
                            size: 18, color: AppColors.textTert)
                      else
                        Icon(
                          provider.unsyncedCount > 0
                              ? Icons.cloud_upload_outlined
                              : Icons.cloud_done_rounded,
                          size: 18,
                          color: provider.unsyncedCount > 0
                              ? AppColors.textSub
                              : const Color(0xFF30D158),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.separator, height: 1),
                  const SizedBox(height: 14),
                  _SyncRow(
                    label: 'Unsynced sessions',
                    value: provider.unsyncedCount.toString(),
                    highlight: provider.unsyncedCount > 0,
                  ),
                  const SizedBox(height: 8),
                  _SyncRow(
                    label: 'Last synced',
                    value: provider.lastSyncTime != null
                        ? _formatTime(provider.lastSyncTime!)
                        : 'Never',
                  ),
                  if (isLoggedIn) ...[
                    const SizedBox(height: 16),
                    Pressable(
                      onTap: provider.isSyncing
                          ? null
                          : () => provider.syncPending(),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.elevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Sync Now',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats summary
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All Time',
                    style: TextStyle(
                      color: AppColors.textSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Workouts',
                          value: provider.sessions
                              .where((s) => s.endTime != null)
                              .length
                              .toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          label: 'This Month',
                          value: provider.sessions
                              .where((s) =>
                                  s.endTime != null &&
                                  s.startTime.month == DateTime.now().month &&
                                  s.startTime.year == DateTime.now().year)
                              .length
                              .toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          label: 'This Week',
                          value: provider.sessions
                              .where((s) =>
                                  s.endTime != null &&
                                  s.startTime.isAfter(DateTime.now()
                                      .subtract(const Duration(days: 7))))
                              .length
                              .toString(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Auth actions
            if (!isLoggedIn)
              Pressable(
                onTap: () => Navigator.of(context).pushNamed('/auth'),
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.text,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Sign In / Create Account',
                    style: TextStyle(
                      color: AppColors.bg,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            if (isLoggedIn)
              Pressable(
                onTap: () => _confirmSignOut(context),
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.destructive.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.destructive,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(t);
  }

  void _confirmSignOut(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your workouts are saved locally and will remain.',
              style: TextStyle(color: AppColors.textSub, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.separator, height: 1),
            GestureDetector(
              onTap: () async {
                Navigator.pop(ctx);
                await SupabaseService.signOut();
              },
              child: const SizedBox(
                height: 54,
                child: Center(
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.destructive,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(color: AppColors.separator, height: 1),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: const SizedBox(
                height: 54,
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _SyncRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SyncRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textSub, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.destructive : AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textTert,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
