import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/workout_provider.dart';
import '../models/workout_session.dart';
import '../models/body_weight.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_ring.dart';
import '../widgets/activity_dots.dart';
import '../widgets/pressable.dart';
import 'active_workout_screen.dart';
import 'session_detail_screen.dart';
import 'charts_screen.dart';
import 'watch_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<WorkoutProvider>();
      p.loadSessions();
      p.loadExercises();
      p.loadBodyWeights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _tab,
        children: const [
          _DashboardTab(),
          _LogsTab(),
          ChartsScreen(),
          WatchScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _GlassTabBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// ─── Frosted Glass Tab Bar ────────────────────────────────────────────────────

class _GlassTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassTabBar({required this.currentIndex, required this.onTap});

  static const _icons = [
    Icons.grid_view_rounded,
    Icons.calendar_month_rounded,
    Icons.bar_chart_rounded,
    Icons.watch_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Home', 'History', 'Progress', 'Watch', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withValues(alpha: 0.92),
            border: const Border(
              top: BorderSide(color: AppColors.separator, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: List.generate(_icons.length, (i) {
                  final active = i == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            child: Icon(
                              _icons[i],
                              size: 22,
                              color: active
                                  ? AppColors.text
                                  : AppColors.textTert,
                            ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(
                              color: active
                                  ? AppColors.text
                                  : AppColors.textTert,
                              fontSize: 10,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            child: Text(_labels[i]),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  void _showLogWeight(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.track,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Log Body Weight',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 20),
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1),
                decoration: const InputDecoration(
                  hintText: '70.0',
                  labelText: 'Weight (kg)',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.text,
                    foregroundColor: AppColors.bg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    final kg = double.tryParse(ctrl.text);
                    if (kg == null || kg <= 0) return;
                    context.read<WorkoutProvider>().addBodyWeight(kg);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resumeOrNewWorkout(BuildContext context) {
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
            const Text('Workout In Progress',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              context.read<WorkoutProvider>().activeSession?.name ?? '',
              style: const TextStyle(
                  color: AppColors.textSub, fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.separator, height: 1),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                    context, _slideRoute(const ActiveWorkoutScreen()));
              },
              child: const SizedBox(
                height: 54,
                child: Center(
                  child: Text('Resume Workout',
                      style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const Divider(color: AppColors.separator, height: 1),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: const SizedBox(
                height: 54,
                child: Center(
                  child: Text('Cancel',
                      style: TextStyle(
                          color: AppColors.textSub, fontSize: 17)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _startWorkout(BuildContext context) {
    final ctrl = TextEditingController(
      text: 'Workout ${DateFormat('MMM d').format(DateTime.now())}',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StartWorkoutSheet(nameCtrl: ctrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    // Only count completed sessions in stats
    final sessions = provider.sessions.where((s) => s.endTime != null).toList();
    final now = DateTime.now();

    final thisWeek = sessions
        .where((s) => s.startTime.isAfter(now.subtract(const Duration(days: 7))))
        .length;
    final totalMin = sessions.fold<int>(0, (s, w) => s + w.duration.inMinutes);
    final activeDates = sessions.map((s) => s.startTime).toList();
    final streak = provider.currentStreak;
    final latestBw = provider.latestBodyWeight;
    final hasActiveSession = provider.activeSession != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Workouts',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
                const Spacer(),
                if (hasActiveSession)
                  Pressable(
                    onTap: () async {
                      await context
                          .read<WorkoutProvider>()
                          .loadSessions();
                      if (context.mounted) {
                        Navigator.push(
                            context,
                            _slideRoute(
                                const ActiveWorkoutScreen()));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.elevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.track, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF30D158),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('In progress',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                  ),
                if (hasActiveSession) const SizedBox(width: 8),
                _HeaderBtn(
                  icon: Icons.add,
                  onTap: () => hasActiveSession
                      ? _resumeOrNewWorkout(context)
                      : _startWorkout(context),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                // Row 1 — Workout ring + Body weight
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _WorkoutRingCard(
                          weekCount: thisWeek,
                          goal: 4,
                          onTap: () => hasActiveSession
                              ? Navigator.push(context,
                                  _slideRoute(const ActiveWorkoutScreen()))
                              : _startWorkout(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BodyWeightCard(
                          bodyWeight: latestBw,
                          onTap: () => _showLogWeight(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Row 2 — Activity dot matrix
                _ActivityCard(
                  activeDates: activeDates,
                  totalSessions: sessions.length,
                ),

                const SizedBox(height: 12),

                // Row 3 — Volume stat
                _VolumeCard(
                  volumeKg: provider.weekVolumeKg,
                  totalMinutes: totalMin,
                ),

                const SizedBox(height: 12),

                // Row 4 — Add + This Week
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _AddCard(
                          onTap: () => _startWorkout(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ThisWeekCard(
                          count: thisWeek,
                          totalMin: totalMin,
                          streak: streak,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Recent sessions
                if (sessions.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Text(
                          'RECENT',
                          style: TextStyle(
                            color: AppColors.textSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${sessions.length} total',
                          style: const TextStyle(
                            color: AppColors.textSub, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ...sessions.take(3).map((s) => _RecentSessionCard(session: s)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Bento Cards ──────────────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.elevated,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.text),
      ),
    );
  }
}

class _WorkoutRingCard extends StatelessWidget {
  final int weekCount;
  final int goal;
  final VoidCallback onTap;

  const _WorkoutRingCard({
    required this.weekCount,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (weekCount / goal).clamp(0.0, 1.0);
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircularRing(
              progress: progress,
              label: '$weekCount',
              size: 64,
            ),
            const SizedBox(height: 12),
            const Text('This week',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 3),
            Text('Goal: $goal workouts',
                style: const TextStyle(
                  color: AppColors.textSub, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _BodyWeightCard extends StatelessWidget {
  final BodyWeight? bodyWeight;
  final VoidCallback onTap;

  const _BodyWeightCard({required this.bodyWeight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasData = bodyWeight != null;
    final weightStr = hasData
        ? (bodyWeight!.weight % 1 == 0
            ? bodyWeight!.weight.toInt().toString()
            : bodyWeight!.weight.toStringAsFixed(1))
        : '—';

    String timeStr = '';
    if (hasData) {
      final diff = DateTime.now().difference(bodyWeight!.loggedAt);
      if (diff.inMinutes < 1) {
        timeStr = 'Just now';
      } else if (diff.inMinutes < 60) {
        timeStr = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        timeStr = '${diff.inHours}h ago';
      } else {
        timeStr = '${diff.inDays}d ago';
      }
    }

    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add,
                      size: 14, color: AppColors.textSub),
                ),
              ],
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: weightStr,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                  ),
                  if (hasData)
                    const TextSpan(
                      text: ' kg',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.3,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text('Body weight',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(
              hasData ? timeStr : 'Tap to log',
              style: const TextStyle(
                  color: AppColors.textSub, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final List<DateTime> activeDates;
  final int totalSessions;

  const _ActivityCard({required this.activeDates, required this.totalSessions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Activity',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$totalSessions sessions',
                style: const TextStyle(
                  color: AppColors.textSub, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ActivityDots(activeDates: activeDates),
        ],
      ),
    );
  }
}

class _VolumeCard extends StatelessWidget {
  final double volumeKg;
  final int totalMinutes;

  const _VolumeCard({required this.volumeKg, required this.totalMinutes});

  @override
  Widget build(BuildContext context) {
    final formatted = volumeKg > 0
        ? NumberFormat('#,###').format(volumeKg.toInt())
        : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Volume lifted',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              const Text('Last 7 days',
                  style: TextStyle(
                    color: AppColors.textSub, fontSize: 12)),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: formatted,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.0,
                  ),
                ),
                const TextSpan(
                  text: ' kg',
                  style: TextStyle(
                    color: AppColors.textSub,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.track,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 28, color: AppColors.textTert),
        ),
      ),
    );
  }
}

class _ThisWeekCard extends StatelessWidget {
  final int count;
  final int totalMin;
  final int streak;
  const _ThisWeekCard(
      {required this.count, required this.totalMin, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 48,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          const Text('This week',
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          if (streak > 0) ...[
            Row(
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    size: 13, color: Color(0xFFFF9F0A)),
                const SizedBox(width: 4),
                Text('$streak day streak',
                    style: const TextStyle(
                        color: Color(0xFFFF9F0A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ] else
            Text('${totalMin ~/ 60}h ${totalMin % 60}m total',
                style: const TextStyle(
                    color: AppColors.textSub, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RecentSessionCard extends StatelessWidget {
  final WorkoutSession session;
  const _RecentSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => Navigator.push(
        context,
        _slideRoute(SessionDetailScreen(session: session)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  session.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('EEE, MMM d · h:mm a').format(session.startTime),
                    style: const TextStyle(
                      color: AppColors.textSub, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${session.duration.inMinutes}m',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 16, color: AppColors.textTert),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Start Workout Bottom Sheet ───────────────────────────────────────────────

class _StartWorkoutSheet extends StatefulWidget {
  final TextEditingController nameCtrl;
  const _StartWorkoutSheet({required this.nameCtrl});

  @override
  State<_StartWorkoutSheet> createState() => _StartWorkoutSheetState();
}

class _StartWorkoutSheetState extends State<_StartWorkoutSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.track,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'New Workout',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: widget.nameCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                  hintText: 'Session name',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.text,
                    foregroundColor: AppColors.bg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await context
                        .read<WorkoutProvider>()
                        .startSession(widget.nameCtrl.text.trim());
                    if (context.mounted) {
                      Navigator.push(
                          context, _slideRoute(const ActiveWorkoutScreen()));
                    }
                  },
                  child: const Text('Start'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Logs Tab ─────────────────────────────────────────────────────────────────

class _LogsTab extends StatelessWidget {
  const _LogsTab();

  @override
  Widget build(BuildContext context) {
    final sessions = context
        .watch<WorkoutProvider>()
        .sessions
        .where((s) => s.endTime != null)
        .toList();

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                const Text(
                  'History',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
                const Spacer(),
                Text(
                  '${sessions.length} workouts',
                  style: const TextStyle(
                    color: AppColors.textSub, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: sessions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center_rounded,
                          size: 48, color: AppColors.track),
                      SizedBox(height: 16),
                      Text('No workouts yet',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          )),
                      SizedBox(height: 6),
                      Text('Start your first session from the dashboard',
                          style: TextStyle(
                            color: AppColors.textSub, fontSize: 13),
                          textAlign: TextAlign.center),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sessions.length,
                  itemBuilder: (_, i) => _LogSessionRow(session: sessions[i]),
                ),
        ),
      ],
    );
  }
}

class _LogSessionRow extends StatelessWidget {
  final WorkoutSession session;
  const _LogSessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.destructive,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) async => await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete workout?',
              style: TextStyle(color: AppColors.text)),
          content: const Text('This action cannot be undone.',
              style: TextStyle(color: AppColors.textSub)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSub)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.destructive)),
            ),
          ],
        ),
      ),
      onDismissed: (_) =>
          context.read<WorkoutProvider>().deleteSession(session.id!),
      child: Pressable(
        onTap: () => Navigator.push(
          context,
          _slideRoute(SessionDetailScreen(session: session)),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    session.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.name,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('EEE, MMM d yyyy').format(session.startTime),
                      style: const TextStyle(
                        color: AppColors.textSub, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${session.duration.inMinutes}m',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Icon(Icons.chevron_right,
                      size: 16, color: AppColors.textTert),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Navigation helper ────────────────────────────────────────────────────────

PageRoute _slideRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (ctx, a, s) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (ctx, anim, s, child) => SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
