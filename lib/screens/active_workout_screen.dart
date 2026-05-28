import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/exercise_log.dart';
import '../theme/app_theme.dart';
import '../widgets/pressable.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  Timer? _elapsedTimer;
  Timer? _restTimer;
  int _elapsedSeconds = 0;
  int _restSecondsLeft = 0;
  static const _restDuration = 90;

  @override
  void initState() {
    super.initState();
    final session = context.read<WorkoutProvider>().activeSession;
    if (session != null) {
      _elapsedSeconds =
          DateTime.now().difference(session.startTime).inSeconds;
    }
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  String get _elapsedFormatted {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() => _restSecondsLeft = _restDuration);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_restSecondsLeft <= 1) {
        _restTimer?.cancel();
        HapticFeedback.mediumImpact();
        setState(() => _restSecondsLeft = 0);
      } else {
        setState(() => _restSecondsLeft--);
      }
    });
  }

  void _cancelRestTimer() {
    _restTimer?.cancel();
    setState(() => _restSecondsLeft = 0);
  }

  Future<void> _showAddSet(BuildContext context, ExerciseLog log) async {
    final provider = context.read<WorkoutProvider>();
    final best =
        await provider.getLastBestForExercise(log.exerciseName);

    if (!context.mounted) return;

    final weightCtrl = TextEditingController();
    final repsCtrl = TextEditingController();

    // Pre-fill with previous best
    if (best != null) {
      weightCtrl.text = (best['weight'] as num).toStringAsFixed(
          (best['weight'] as num) % 1 == 0 ? 0 : 1);
      repsCtrl.text = '${best['reps']}';
    }

    await showModalBottomSheet(
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
              const SizedBox(height: 16),
              Text(
                'Set ${log.sets.length + 1}  ·  ${log.exerciseName}',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (best != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Last: ${(best['weight'] as num).toStringAsFixed((best['weight'] as num) % 1 == 0 ? 0 : 1)} kg × ${best['reps']} reps',
                  style: const TextStyle(
                    color: AppColors.textSub,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SetField(
                      controller: weightCtrl,
                      label: 'Weight (kg)',
                      autofocus: true,
                      isDecimal: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SetField(
                      controller: repsCtrl,
                      label: 'Reps',
                    ),
                  ),
                ],
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
                    final w = double.tryParse(weightCtrl.text);
                    final r = int.tryParse(repsCtrl.text);
                    if (w == null || r == null || r <= 0) return;
                    context.read<WorkoutProvider>().addSet(log.id!, w, r);
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                    _startRestTimer();
                  },
                  child: const Text('Log Set'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExercisePicker(BuildContext context) {
    final provider = context.read<WorkoutProvider>();
    final groups = provider.exercises.map((e) => e.muscleGroup).toSet().toList()
      ..sort();
    String? selectedGroup = groups.isNotEmpty ? groups.first : null;
    final searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final query = searchCtrl.text.toLowerCase();
          final filtered = provider.exercises.where((e) {
            final matchGroup =
                selectedGroup == null || e.muscleGroup == selectedGroup;
            final matchSearch = query.isEmpty ||
                e.name.toLowerCase().contains(query) ||
                e.equipment.toLowerCase().contains(query);
            return matchGroup && matchSearch;
          }).toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            expand: false,
            builder: (ctx2, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
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
                  const SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text('Add Exercise',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            )),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _showCreateExercise(context);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.elevated,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add,
                                size: 18, color: AppColors.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setSheetState(() {}),
                      style: const TextStyle(
                          color: AppColors.text, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search exercises…',
                        prefixIcon: const Icon(Icons.search,
                            size: 18, color: AppColors.textTert),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: AppColors.elevated,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Muscle group filter chips
                  if (query.isEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: groups
                            .map((g) => Padding(
                                  padding:
                                      const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setSheetState(
                                        () => selectedGroup = g),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 150),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8),
                                      decoration: BoxDecoration(
                                        color: selectedGroup == g
                                            ? AppColors.text
                                            : AppColors.elevated,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(g,
                                          style: TextStyle(
                                            color: selectedGroup == g
                                                ? AppColors.bg
                                                : AppColors.text,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text('No exercises found',
                                style: TextStyle(
                                    color: AppColors.textSub,
                                    fontSize: 14)),
                          )
                        : ListView.builder(
                            controller: scrollCtrl,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            itemCount: filtered.length,
                            itemBuilder: (bctx, i) {
                              final e = filtered[i];
                              return Pressable(
                                onTap: () {
                                  context
                                      .read<WorkoutProvider>()
                                      .addExerciseToSession(e);
                                  Navigator.pop(ctx);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 8),
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.elevated,
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(e.name,
                                                style: const TextStyle(
                                                  color: AppColors.text,
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w500,
                                                )),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${e.muscleGroup}  ·  ${e.equipment}',
                                              style: const TextStyle(
                                                color:
                                                    AppColors.textSub,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                          Icons.add_circle_outline,
                                          size: 20,
                                          color: AppColors.textSub),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateExercise(BuildContext context) {
    final nameCtrl = TextEditingController();
    String muscleGroup = 'Chest';
    String equipment = 'Barbell';
    const groups = [
      'Chest', 'Back', 'Shoulders', 'Legs', 'Arms', 'Core', 'Cardio'
    ];
    const equips = [
      'Barbell', 'Dumbbell', 'Cable', 'Machine', 'Bodyweight', 'Other'
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Exercise',
              style: TextStyle(
                  color: AppColors.text, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.text),
                decoration:
                    const InputDecoration(hintText: 'Exercise name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: muscleGroup,
                dropdownColor: AppColors.elevated,
                style: const TextStyle(color: AppColors.text),
                decoration:
                    const InputDecoration(labelText: 'Muscle group'),
                items: groups
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g,
                              style: const TextStyle(
                                  color: AppColors.text)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => muscleGroup = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: equipment,
                dropdownColor: AppColors.elevated,
                style: const TextStyle(color: AppColors.text),
                decoration:
                    const InputDecoration(labelText: 'Equipment'),
                items: equips
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style: const TextStyle(
                                  color: AppColors.text)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => equipment = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSub)),
            ),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                context.read<WorkoutProvider>().addCustomExercise(
                    nameCtrl.text.trim(), muscleGroup, equipment);
                Navigator.pop(ctx);
              },
              child: const Text('Save',
                  style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinishSheet(BuildContext context) {
    final notesCtrl = TextEditingController();
    final hrCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final provider = context.read<WorkoutProvider>();
    final session = provider.activeSession!;
    final elapsed = DateTime.now().difference(session.startTime);
    final min = elapsed.inMinutes;
    final exerciseCount = provider.activeLogs.length;
    final setCount =
        provider.activeLogs.fold(0, (s, l) => s + l.sets.length);

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
              const Text(
                'Finish Workout',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              // Quick stats
              Row(
                children: [
                  _FinishStat(
                      label: 'Duration', value: '${min}m'),
                  const SizedBox(width: 10),
                  _FinishStat(
                      label: 'Exercises',
                      value: '$exerciseCount'),
                  const SizedBox(width: 10),
                  _FinishStat(
                      label: 'Sets', value: '$setCount'),
                ],
              ),
              const SizedBox(height: 20),
              // Notes
              TextField(
                controller: notesCtrl,
                style: const TextStyle(color: AppColors.text),
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Notes (optional)',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FinishField(
                      controller: hrCtrl,
                      label: 'Heart rate',
                      hint: 'bpm',
                      icon: Icons.favorite_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FinishField(
                      controller: calCtrl,
                      label: 'Calories',
                      hint: 'kcal',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                  onPressed: () async {
                    Navigator.pop(ctx);
                    _cancelRestTimer();
                    await context.read<WorkoutProvider>().finishSession(
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                          heartRate: int.tryParse(hrCtrl.text),
                          calories: int.tryParse(calCtrl.text),
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save Workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final provider = context.read<WorkoutProvider>();
    if (provider.activeLogs.isEmpty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard workout?',
            style: TextStyle(
                color: AppColors.text, fontWeight: FontWeight.w600)),
        content: const Text(
            'Your sets will be lost. Finish the workout instead to save it.',
            style: TextStyle(color: AppColors.textSub)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going',
                style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard',
                style: TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final session = provider.activeSession;
    if (session == null) return const SizedBox();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _confirmDiscard(context);
        if (ok && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () async {
            final ok = await _confirmDiscard(context);
            if (ok && context.mounted) Navigator.pop(context);
          },
          child: const Icon(Icons.chevron_left,
              color: AppColors.text, size: 28),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.name,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _elapsedFormatted,
              style: const TextStyle(
                color: AppColors.textSub,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => _showFinishSheet(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Finish',
                  style: TextStyle(
                    color: AppColors.bg,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          provider.activeLogs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.fitness_center_rounded,
                            size: 36, color: AppColors.textTert),
                      ),
                      const SizedBox(height: 20),
                      const Text('No exercises yet',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 6),
                      const Text('Tap below to add your first exercise',
                          style: TextStyle(
                              color: AppColors.textSub, fontSize: 14)),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => _showExercisePicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.track, width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  size: 18, color: AppColors.text),
                              SizedBox(width: 8),
                              Text('Add Exercise',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: provider.activeLogs.length,
                  itemBuilder: (bctx, i) => _ExerciseLogCard(
                    log: provider.activeLogs[i],
                    onAddSet: () =>
                        _showAddSet(context, provider.activeLogs[i]),
                  ),
                ),

          // Rest timer banner — raised above FAB when exercises exist
          if (_restSecondsLeft > 0)
            Positioned(
              bottom: provider.activeLogs.isNotEmpty ? 76 : 16,
              left: 16,
              right: 16,
              child: _RestTimerBanner(
                secondsLeft: _restSecondsLeft,
                total: _restDuration,
                onSkip: _cancelRestTimer,
              ),
            ),
        ],
      ),
      floatingActionButton: provider.activeLogs.isNotEmpty
          ? GestureDetector(
              onTap: () => _showExercisePicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 20, color: AppColors.text),
                    SizedBox(width: 8),
                    Text('Add Exercise',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            )
          : null,
      ),
    );
  }
}

// ─── Rest Timer Banner ────────────────────────────────────────────────────────

class _RestTimerBanner extends StatelessWidget {
  final int secondsLeft;
  final int total;
  final VoidCallback onSkip;

  const _RestTimerBanner({
    required this.secondsLeft,
    required this.total,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final progress = secondsLeft / total;
    final m = secondsLeft ~/ 60;
    final s = secondsLeft % 60;
    final label =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.separator, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: AppColors.track,
                  color: AppColors.text,
                ),
                Text(
                  label.startsWith('00:') ? label.substring(3) : label,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rest',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$label remaining',
                  style: const TextStyle(
                    color: AppColors.textSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSkip,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.textSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Exercise Log Card ────────────────────────────────────────────────────────

class _ExerciseLogCard extends StatelessWidget {
  final ExerciseLog log;
  final VoidCallback onAddSet;

  const _ExerciseLogCard({required this.log, required this.onAddSet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: Text(log.exerciseName,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              GestureDetector(
                onTap: () => context
                    .read<WorkoutProvider>()
                    .removeExerciseLog(log.id!),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close,
                      size: 14, color: AppColors.destructive),
                ),
              ),
            ],
          ),
          if (log.sets.isNotEmpty) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: const [
                  SizedBox(
                    width: 44,
                    child: Text('SET',
                        style: TextStyle(
                            color: AppColors.textSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8)),
                  ),
                  Expanded(
                    child: Text('WEIGHT',
                        style: TextStyle(
                            color: AppColors.textSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8)),
                  ),
                  Expanded(
                    child: Text('REPS',
                        style: TextStyle(
                            color: AppColors.textSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8)),
                  ),
                  SizedBox(width: 32),
                ],
              ),
            ),
            ...log.sets.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text('${s.setNumber}',
                            style: const TextStyle(
                                color: AppColors.textSub, fontSize: 15)),
                      ),
                      Expanded(
                        child: Text(
                          s.weight % 1 == 0
                              ? '${s.weight.toInt()} kg'
                              : '${s.weight} kg',
                          style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text('${s.reps}',
                            style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ),
                      GestureDetector(
                        onTap: () => context
                            .read<WorkoutProvider>()
                            .removeSet(log.id!, s.id!),
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.textTert),
                      ),
                    ],
                  ),
                )),
            Container(height: 0.5, color: AppColors.separator),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 12),
          GestureDetector(
            onTap: onAddSet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 16, color: AppColors.textSub),
                  SizedBox(width: 6),
                  Text('Add Set',
                      style: TextStyle(
                          color: AppColors.textSub,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final bool isDecimal;

  const _SetField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: const TextStyle(
          color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w500),
      keyboardType: isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '0',
        labelText: label,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _FinishStat extends StatelessWidget {
  final String label;
  final String value;
  const _FinishStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                )),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textTert,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _FinishField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  const _FinishField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(icon, size: 16, color: AppColors.textTert),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
