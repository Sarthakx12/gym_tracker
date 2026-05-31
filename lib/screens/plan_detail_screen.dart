import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_plan.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pressable.dart';
import 'active_workout_screen.dart';

class PlanDetailScreen extends StatelessWidget {
  final WorkoutPlan plan;
  const PlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _PlanAppBar(plan: plan),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _DayCard(day: plan.days[i], plan: plan),
                childCount: plan.days.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanAppBar extends StatelessWidget {
  final WorkoutPlan plan;
  const _PlanAppBar({required this.plan});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 180,
      backgroundColor: AppColors.bg,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: AppColors.text),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          color: AppColors.bg,
          padding: const EdgeInsets.fromLTRB(20, 96, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _GoalBadge(plan.goal),
                  const SizedBox(width: 8),
                  _DiffBadge(plan.difficulty),
                  if (plan.isAiGenerated) ...[
                    const SizedBox(width: 8),
                    _Badge(
                      label: 'AI Generated',
                      color: const Color(0xFFBF5AF2),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(
                plan.name,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 12, color: AppColors.textSub),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.daysPerWeek} days / week',
                    style: const TextStyle(
                        color: AppColors.textSub, fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.fitness_center_rounded,
                      size: 12, color: AppColors.textSub),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.days.where((d) => !d.isRest).length} training days',
                    style: const TextStyle(
                        color: AppColors.textSub, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        title: Text(
          plan.name,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final WorkoutPlanDay day;
  final WorkoutPlan plan;
  const _DayCard({required this.day, required this.plan});

  @override
  Widget build(BuildContext context) {
    if (day.isRest) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.separator, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bedtime_rounded,
                  size: 16, color: AppColors.textTert),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.dayName,
                    style: const TextStyle(
                      color: AppColors.textSub,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 2),
                const Text('Rest & Recovery',
                    style: TextStyle(
                        color: AppColors.textTert, fontSize: 12)),
              ],
            ),
          ],
        ),
      );
    }

    return Pressable(
      onTap: () => _showDaySheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    day.dayName,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${day.exercises.length} exercises',
                  style: const TextStyle(
                      color: AppColors.textSub, fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 16, color: AppColors.textTert),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: day.focus
                  .map((f) => _FocusChip(label: f))
                  .toList(),
            ),
            const SizedBox(height: 10),
            ...day.exercises.take(3).map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.textTert,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${e.name}  ${e.sets}×${e.repsRange}',
                        style: const TextStyle(
                          color: AppColors.textSub,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (day.exercises.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+ ${day.exercises.length - 3} more',
                  style: const TextStyle(
                      color: AppColors.textTert, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDaySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DayDetailSheet(day: day, plan: plan),
    );
  }
}

class _DayDetailSheet extends StatelessWidget {
  final WorkoutPlanDay day;
  final WorkoutPlan plan;
  const _DayDetailSheet({required this.day, required this.plan});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.track,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.dayName,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: day.focus
                        .map((f) => _FocusChip(label: f))
                        .toList(),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.separator, height: 1),
            Expanded(
              child: ListView.builder(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: day.exercises.length,
                itemBuilder: (_, i) =>
                    _ExerciseRow(exercise: day.exercises[i], index: i),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
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
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final name =
                        '${plan.name} — ${day.dayName.split('—').last.trim()}';
                    await context
                        .read<WorkoutProvider>()
                        .startSession(name);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        _slideRoute(const ActiveWorkoutScreen()),
                      );
                    }
                  },
                  child: const Text('Start This Workout'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final PlanExercise exercise;
  final int index;
  const _ExerciseRow({required this.exercise, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.track,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.textSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _StatPill(
                        label:
                            '${exercise.sets} sets × ${exercise.repsRange}'),
                    const SizedBox(width: 6),
                    _StatPill(
                        label: exercise.restSeconds >= 60
                            ? '${exercise.restSeconds ~/ 60}m rest'
                            : '${exercise.restSeconds}s rest'),
                  ],
                ),
                if (exercise.notes != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    exercise.notes!,
                    style: const TextStyle(
                      color: AppColors.textTert,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  const _StatPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(color: AppColors.textSub, fontSize: 11)),
    );
  }
}

class _FocusChip extends StatelessWidget {
  final String label;
  const _FocusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.textSub,
              fontSize: 11,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _GoalBadge extends StatelessWidget {
  final PlanGoal goal;
  const _GoalBadge(this.goal);

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (goal) {
      PlanGoal.muscle => ('Hypertrophy', const Color(0xFF30D158)),
      PlanGoal.vtaper => ('Aesthetic', const Color(0xFF0A84FF)),
      PlanGoal.powerlifting => ('Strength', const Color(0xFFFF9F0A)),
      PlanGoal.fatLoss => ('Fat Loss', const Color(0xFFFF453A)),
      PlanGoal.general => ('General', AppColors.textSub),
    };
    return _Badge(label: label, color: color);
  }
}

class _DiffBadge extends StatelessWidget {
  final PlanDifficulty diff;
  const _DiffBadge(this.diff);

  @override
  Widget build(BuildContext context) {
    final label = switch (diff) {
      PlanDifficulty.beginner => 'Beginner',
      PlanDifficulty.intermediate => 'Intermediate',
      PlanDifficulty.advanced => 'Advanced',
    };
    return _Badge(label: label, color: AppColors.textSub);
  }
}

PageRoute _slideRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (ctx, a, s) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (ctx, anim, s, child) => SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
