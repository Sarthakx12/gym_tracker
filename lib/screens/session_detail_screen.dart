import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/workout_provider.dart';
import '../models/workout_session.dart';
import '../models/exercise_log.dart';
import '../theme/app_theme.dart';

class SessionDetailScreen extends StatefulWidget {
  final WorkoutSession session;
  const SessionDetailScreen({super.key, required this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  List<ExerciseLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs =
        await context.read<WorkoutProvider>().getSessionLogs(widget.session.id!);
    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final totalVolume = _logs.fold<double>(
        0, (sum, l) => sum + l.sets.fold(0.0, (s2, set) => s2 + set.weight * set.reps));
    final totalSets = _logs.fold<int>(0, (sum, l) => sum + l.sets.length);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left,
              color: AppColors.text, size: 28),
        ),
        title: Text(s.name,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.text, strokeWidth: 2))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetaRow(
                          icon: Icons.calendar_today_outlined,
                          text: DateFormat('EEEE, MMMM d yyyy')
                              .format(s.startTime),
                        ),
                        const SizedBox(height: 10),
                        _MetaRow(
                          icon: Icons.timer_outlined,
                          text: '${s.duration.inMinutes} minutes',
                        ),
                        if (s.heartRate != null) ...[
                          const SizedBox(height: 10),
                          _MetaRow(
                            icon: Icons.favorite_border_rounded,
                            text: '${s.heartRate} bpm avg',
                          ),
                        ],
                        if (s.calories != null) ...[
                          const SizedBox(height: 10),
                          _MetaRow(
                            icon: Icons.local_fire_department_outlined,
                            text: '${s.calories} kcal',
                          ),
                        ],
                        if (s.notes != null && s.notes!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(height: 0.5, color: AppColors.separator),
                          const SizedBox(height: 14),
                          Text(s.notes!,
                              style: const TextStyle(
                                color: AppColors.textSub,
                                fontSize: 14,
                              )),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Stats row
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                              label: 'Exercises',
                              value: '${_logs.length}'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatTile(
                              label: 'Total Sets',
                              value: '$totalSets'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatTile(
                              label: 'Volume',
                              value: '${totalVolume.toInt()} kg'),
                        ),
                      ],
                    ),
                  ),

                  if (_logs.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'EXERCISES',
                      style: TextStyle(
                        color: AppColors.textSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._logs.map((l) => _ExerciseDetailCard(log: l)),
                  ],
                ],
              ),
            ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSub),
        const SizedBox(width: 10),
        Text(text,
            style: const TextStyle(
              color: AppColors.text, fontSize: 14)),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
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
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                color: AppColors.textSub, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ExerciseDetailCard extends StatelessWidget {
  final ExerciseLog log;
  const _ExerciseDetailCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final bestSet = log.sets.isEmpty
        ? null
        : log.sets.reduce((a, b) => a.weight > b.weight ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(18),
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
                child: Text(log.exerciseName,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              if (bestSet != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Best ${bestSet.weight % 1 == 0 ? bestSet.weight.toInt() : bestSet.weight}kg × ${bestSet.reps}',
                    style: const TextStyle(
                      color: AppColors.textSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          if (log.sets.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...log.sets.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Text('Set ${s.setNumber}',
                        style: const TextStyle(
                          color: AppColors.textTert,
                          fontSize: 13,
                        )),
                  ),
                  Text(
                    '${s.weight % 1 == 0 ? s.weight.toInt() : s.weight} kg',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text('  ×  ',
                      style: TextStyle(
                          color: AppColors.textTert, fontSize: 13)),
                  Text('${s.reps} reps',
                      style: const TextStyle(
                        color: AppColors.text, fontSize: 14)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}
