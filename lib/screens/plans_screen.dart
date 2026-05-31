import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_plan.dart';
import '../data/curated_plans.dart';
import '../providers/workout_provider.dart';
import '../services/ai_plan_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pressable.dart';
import '../config/app_config.dart';
import 'plan_detail_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});
  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  int _cardioDuration = 30;
  CardioIntensity _cardioIntensity = CardioIntensity.medium;
  WorkoutPlan? _aiPlan;

  List<CardioWorkout> get _filteredCardio => cardioWorkouts
      .where((c) =>
          c.durationMin == _cardioDuration &&
          c.intensity == _cardioIntensity)
      .toList();

  @override
  Widget build(BuildContext context) {
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
                  'Plans',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
                const Spacer(),
                _AiButton(
                  onTap: () => _showAiGenerator(context),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Generated plan banner (if exists)
                if (_aiPlan != null) ...[
                  _SectionLabel(label: 'YOUR AI PLAN'),
                  const SizedBox(height: 10),
                  _AiPlanBanner(
                    plan: _aiPlan!,
                    onTap: () => _openPlan(context, _aiPlan!),
                    onClear: () => setState(() => _aiPlan = null),
                  ),
                  const SizedBox(height: 20),
                ],

                // Curated programs
                _SectionLabel(label: 'PROGRAMS'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: curatedPlans.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (_, i) => _PlanCard(
                      plan: curatedPlans[i],
                      onTap: () => _openPlan(context, curatedPlans[i]),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Cardio section
                _SectionLabel(label: 'CARDIO'),
                const SizedBox(height: 12),

                // Duration filter
                const Text(
                  'Duration',
                  style: TextStyle(
                    color: AppColors.textSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [15, 30, 45, 60].map((min) {
                    final selected = _cardioDuration == min;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: '${min}m',
                          selected: selected,
                          onTap: () =>
                              setState(() => _cardioDuration = min),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // Intensity filter
                const Text(
                  'Intensity',
                  style: TextStyle(
                    color: AppColors.textSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: CardioIntensity.values.map((i) {
                    final selected = _cardioIntensity == i;
                    final label = switch (i) {
                      CardioIntensity.low => 'Low',
                      CardioIntensity.medium => 'Medium',
                      CardioIntensity.high => 'High',
                    };
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: label,
                          selected: selected,
                          onTap: () =>
                              setState(() => _cardioIntensity = i),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Cardio results
                if (_filteredCardio.isEmpty)
                  _EmptyCardio()
                else
                  ..._filteredCardio.map(
                    (c) => _CardioCard(workout: c),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openPlan(BuildContext context, WorkoutPlan plan) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, a, s) => PlanDetailScreen(plan: plan),
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
      ),
    );
  }

  void _showAiGenerator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AiGeneratorSheet(
        initialWeight:
            context.read<WorkoutProvider>().latestBodyWeight?.weight,
        onPlanGenerated: (plan) {
          setState(() => _aiPlan = plan);
          _openPlan(context, plan);
        },
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSub,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }
}

// ─── Plan Card ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final WorkoutPlan plan;
  final VoidCallback onTap;
  const _PlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (accentColor, iconData) = _planStyle(plan.goal);

    return Pressable(
      onTap: onTap,
      child: SizedBox(
        width: 180,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: accentColor.withValues(alpha: 0.25), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, size: 20, color: accentColor),
              ),
              const Spacer(),
              Text(
                plan.name,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              Text(
                '${plan.daysPerWeek} days/week',
                style: const TextStyle(
                    color: AppColors.textSub, fontSize: 12),
              ),
              const SizedBox(height: 4),
              _GoalPill(goal: plan.goal, color: accentColor),
            ],
          ),
        ),
      ),
    );
  }

  static (Color, IconData) _planStyle(PlanGoal goal) => switch (goal) {
        PlanGoal.muscle => (
            const Color(0xFF30D158),
            Icons.fitness_center_rounded
          ),
        PlanGoal.vtaper => (
            const Color(0xFF0A84FF),
            Icons.self_improvement_rounded
          ),
        PlanGoal.powerlifting => (
            const Color(0xFFFF9F0A),
            Icons.bolt_rounded
          ),
        PlanGoal.fatLoss => (
            const Color(0xFFFF453A),
            Icons.local_fire_department_rounded
          ),
        PlanGoal.general => (AppColors.textSub, Icons.emoji_events_rounded),
      };
}

class _GoalPill extends StatelessWidget {
  final PlanGoal goal;
  final Color color;
  const _GoalPill({required this.goal, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = switch (goal) {
      PlanGoal.muscle => 'Hypertrophy',
      PlanGoal.vtaper => 'Aesthetic',
      PlanGoal.powerlifting => 'Strength',
      PlanGoal.fatLoss => 'Fat Loss',
      PlanGoal.general => 'General',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── AI Plan Banner ───────────────────────────────────────────────────────────

class _AiPlanBanner extends StatelessWidget {
  final WorkoutPlan plan;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const _AiPlanBanner(
      {required this.plan, required this.onTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFBF5AF2).withValues(alpha: 0.3),
              width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFBF5AF2).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 20, color: Color(0xFFBF5AF2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                  Text(
                    '${plan.daysPerWeek} days/week · ${plan.days.where((d) => !d.isRest).length} training days',
                    style: const TextStyle(
                        color: AppColors.textSub, fontSize: 12),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close_rounded,
                  size: 18, color: AppColors.textTert),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── AI Button ────────────────────────────────────────────────────────────────

class _AiButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AiButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFBF5AF2).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFFBF5AF2).withValues(alpha: 0.4),
              width: 0.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded,
                size: 14, color: Color(0xFFBF5AF2)),
            SizedBox(width: 5),
            Text(
              'AI Plan',
              style: TextStyle(
                color: Color(0xFFBF5AF2),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 36,
        decoration: BoxDecoration(
          color: selected ? AppColors.text : AppColors.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.bg : AppColors.textSub,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Cardio Card ──────────────────────────────────────────────────────────────

class _CardioCard extends StatelessWidget {
  final CardioWorkout workout;
  const _CardioCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => _showCardioSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
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
                color: _intensityColor(workout.intensity)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _typeIcon(workout.type),
                size: 22,
                color: _intensityColor(workout.intensity),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 4),
                  Text(workout.description,
                      style: const TextStyle(
                          color: AppColors.textSub, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _IntensityBadge(intensity: workout.intensity),
                const SizedBox(height: 4),
                Text(
                  '~${(workout.caloriesPerKg * 70).round()} kcal',
                  style: const TextStyle(
                      color: AppColors.textTert, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCardioSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CardioDetailSheet(workout: workout),
    );
  }

  static Color _intensityColor(CardioIntensity i) => switch (i) {
        CardioIntensity.low => const Color(0xFF30D158),
        CardioIntensity.medium => const Color(0xFFFF9F0A),
        CardioIntensity.high => const Color(0xFFFF453A),
      };

  static IconData _typeIcon(CardioType t) => switch (t) {
        CardioType.running => Icons.directions_run_rounded,
        CardioType.cycling => Icons.directions_bike_rounded,
        CardioType.rowing => Icons.rowing_rounded,
        CardioType.jumpRope => Icons.sports_martial_arts_rounded,
        CardioType.hiit => Icons.flash_on_rounded,
        CardioType.walking => Icons.directions_walk_rounded,
      };
}

class _IntensityBadge extends StatelessWidget {
  final CardioIntensity intensity;
  const _IntensityBadge({required this.intensity});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (intensity) {
      CardioIntensity.low => ('Low', const Color(0xFF30D158)),
      CardioIntensity.medium => ('Medium', const Color(0xFFFF9F0A)),
      CardioIntensity.high => ('High', const Color(0xFFFF453A)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyCardio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.directions_run_rounded,
                size: 32, color: AppColors.track),
            SizedBox(height: 10),
            Text('No workouts for this combination',
                style: TextStyle(color: AppColors.textSub, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ─── Cardio Detail Sheet ──────────────────────────────────────────────────────

class _CardioDetailSheet extends StatelessWidget {
  final CardioWorkout workout;
  const _CardioDetailSheet({required this.workout});

  @override
  Widget build(BuildContext context) {
    final color = _intensityColor(workout.intensity);

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 24 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.track,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_typeIcon(workout.type), size: 24, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.name,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _IntensityBadge(intensity: workout.intensity),
                        const SizedBox(width: 8),
                        Text('${workout.durationMin} min',
                            style: const TextStyle(
                                color: AppColors.textSub, fontSize: 12)),
                        const SizedBox(width: 8),
                        Text(
                          '~${(workout.caloriesPerKg * 70).round()} kcal (70 kg)',
                          style: const TextStyle(
                              color: AppColors.textSub, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(workout.description,
              style: const TextStyle(
                  color: AppColors.textSub, fontSize: 14, height: 1.5)),
          const SizedBox(height: 20),
          const Text('STRUCTURE',
              style: TextStyle(
                  color: AppColors.textTert,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          ...workout.structure.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                            color: AppColors.textSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                          color: AppColors.text, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _intensityColor(CardioIntensity i) => switch (i) {
        CardioIntensity.low => const Color(0xFF30D158),
        CardioIntensity.medium => const Color(0xFFFF9F0A),
        CardioIntensity.high => const Color(0xFFFF453A),
      };

  static IconData _typeIcon(CardioType t) => switch (t) {
        CardioType.running => Icons.directions_run_rounded,
        CardioType.cycling => Icons.directions_bike_rounded,
        CardioType.rowing => Icons.rowing_rounded,
        CardioType.jumpRope => Icons.sports_martial_arts_rounded,
        CardioType.hiit => Icons.flash_on_rounded,
        CardioType.walking => Icons.directions_walk_rounded,
      };
}

// ─── AI Generator Sheet ───────────────────────────────────────────────────────

class _AiGeneratorSheet extends StatefulWidget {
  final double? initialWeight;
  final void Function(WorkoutPlan plan) onPlanGenerated;

  const _AiGeneratorSheet({
    required this.initialWeight,
    required this.onPlanGenerated,
  });

  @override
  State<_AiGeneratorSheet> createState() => _AiGeneratorSheetState();
}

class _AiGeneratorSheetState extends State<_AiGeneratorSheet> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  PlanGoal _goal = PlanGoal.muscle;
  int _days = 4;
  PlanDifficulty _experience = PlanDifficulty.intermediate;
  String _equipment = 'Full Gym';

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialWeight != null) {
      _weightCtrl.text = widget.initialWeight!.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final weight = double.tryParse(_weightCtrl.text);
    final height = int.tryParse(_heightCtrl.text);
    final age = int.tryParse(_ageCtrl.text);

    if (weight == null || height == null || age == null) {
      setState(() => _error = 'Please fill in weight, height, and age');
      return;
    }

    if (AppConfig.anthropicApiKey.isEmpty) {
      setState(() => _error =
          'Add your Anthropic API key in lib/config/app_config.dart to use AI plans');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final plan = await AiPlanService.generatePlan(AiPlanParams(
        bodyWeightKg: weight,
        heightCm: height,
        age: age,
        goal: _goal,
        daysPerWeek: _days,
        experience: _experience,
        equipment: _equipment,
      ));
      if (mounted) {
        Navigator.pop(context);
        widget.onPlanGenerated(plan);
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().contains('no_api_key')
            ? 'Add your Anthropic API key in lib/config/app_config.dart'
            : 'Generation failed. Check your API key and internet connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      size: 18, color: Color(0xFFBF5AF2)),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Plan Generator',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.separator, height: 1),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  // Body stats
                  const Text('BODY STATS',
                      style: TextStyle(
                          color: AppColors.textTert,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: _InputField(
                          ctrl: _weightCtrl,
                          label: 'Weight (kg)',
                          hint: '75'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InputField(
                          ctrl: _heightCtrl,
                          label: 'Height (cm)',
                          hint: '178'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InputField(
                          ctrl: _ageCtrl, label: 'Age', hint: '25'),
                    ),
                  ]),

                  const SizedBox(height: 20),
                  const Text('GOAL',
                      style: TextStyle(
                          color: AppColors.textTert,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      (PlanGoal.muscle, 'Muscle Building'),
                      (PlanGoal.vtaper, 'V-Taper'),
                      (PlanGoal.fatLoss, 'Fat Loss'),
                      (PlanGoal.powerlifting, 'Powerlifting'),
                      (PlanGoal.general, 'General Fitness'),
                    ].map((entry) {
                      final (goal, label) = entry;
                      final selected = _goal == goal;
                      return GestureDetector(
                        onTap: () => setState(() => _goal = goal),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.text
                                : AppColors.elevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(label,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.bg
                                    : AppColors.textSub,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Text('TRAINING DAYS / WEEK',
                      style: TextStyle(
                          color: AppColors.textTert,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Row(
                    children: [3, 4, 5, 6].map((d) {
                      final selected = _days == d;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _days = d),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              height: 40,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.text
                                    : AppColors.elevated,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '$d',
                                  style: TextStyle(
                                    color: selected
                                        ? AppColors.bg
                                        : AppColors.textSub,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Text('EXPERIENCE LEVEL',
                      style: TextStyle(
                          color: AppColors.textTert,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      (PlanDifficulty.beginner, 'Beginner'),
                      (PlanDifficulty.intermediate, 'Intermediate'),
                      (PlanDifficulty.advanced, 'Advanced'),
                    ].asMap().entries.map((e) {
                      final (diff, label) = e.value;
                      final selected = _experience == diff;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _experience = diff),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              height: 40,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.text
                                    : AppColors.elevated,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(label,
                                    style: TextStyle(
                                      color: selected
                                          ? AppColors.bg
                                          : AppColors.textSub,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Text('EQUIPMENT',
                      style: TextStyle(
                          color: AppColors.textTert,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Full Gym',
                      'Dumbbells Only',
                      'Bodyweight Only',
                    ].map((eq) {
                      final selected = _equipment == eq;
                      return GestureDetector(
                        onTap: () => setState(() => _equipment = eq),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.text
                                : AppColors.elevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(eq,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.bg
                                    : AppColors.textSub,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      );
                    }).toList(),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.destructive.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(
                              color: AppColors.destructive,
                              fontSize: 13)),
                    ),
                  ],

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _loading
                            ? AppColors.elevated
                            : const Color(0xFFBF5AF2),
                        foregroundColor: AppColors.text,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: _loading ? null : _generate,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.text,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_rounded, size: 16),
                                SizedBox(width: 8),
                                Text('Generate My Plan'),
                              ],
                            ),
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

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  const _InputField(
      {required this.ctrl, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
          color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            const TextStyle(color: AppColors.textTert, fontSize: 11),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
    );
  }
}
