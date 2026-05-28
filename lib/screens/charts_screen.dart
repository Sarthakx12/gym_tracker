import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  List<Map<String, dynamic>> _volumeData = [];
  List<Map<String, dynamic>> _progressData = [];
  String? _selectedExercise;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVolume();
  }

  Future<void> _loadVolume() async {
    final data = await context.read<WorkoutProvider>().getVolumeData();
    setState(() {
      _volumeData = data;
      _loading = false;
    });
  }

  Future<void> _loadProgress(String exercise) async {
    setState(() => _loading = true);
    final data = await context.read<WorkoutProvider>().getProgressData(exercise);
    setState(() {
      _progressData = data;
      _selectedExercise = exercise;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercises = context.watch<WorkoutProvider>().exercises;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.text, strokeWidth: 2))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Volume section
                      const Text(
                        'VOLUME',
                        style: TextStyle(
                          color: AppColors.textSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _volumeData.isEmpty
                            ? _EmptyState(
                                message: 'Log workouts to see volume chart')
                            : SizedBox(
                                height: 200,
                                child: _VolumeChart(data: _volumeData)),
                      ),

                      const SizedBox(height: 24),

                      // Exercise progress section
                      const Text(
                        'EXERCISE PROGRESS',
                        style: TextStyle(
                          color: AppColors.textSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Exercise selector
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedExercise,
                            isExpanded: true,
                            dropdownColor: AppColors.elevated,
                            hint: const Text('Select exercise',
                                style: TextStyle(
                                    color: AppColors.textSub, fontSize: 14)),
                            icon: const Icon(Icons.expand_more_rounded,
                                color: AppColors.textSub),
                            style: const TextStyle(
                                color: AppColors.text, fontSize: 14),
                            items: exercises
                                .map((e) => DropdownMenuItem(
                                      value: e.name,
                                      child: Text(e.name,
                                          style: const TextStyle(
                                              color: AppColors.text)),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) _loadProgress(v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_selectedExercise != null)
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _progressData.isEmpty
                              ? _EmptyState(
                                  message:
                                      'No data for this exercise yet')
                              : SizedBox(
                                  height: 200,
                                  child: _ProgressChart(
                                    data: _progressData,
                                    exercise: _selectedExercise!,
                                  )),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart_rounded,
                size: 32, color: AppColors.track),
            const SizedBox(height: 10),
            Text(message,
                style: const TextStyle(
                    color: AppColors.textSub, fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _VolumeChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _VolumeChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.fold<double>(
        0,
        (m, d) => (d['volume'] as num).toDouble() > m
            ? (d['volume'] as num).toDouble()
            : m);

    final bars = data.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: (e.value['volume'] as num).toDouble(),
            color: AppColors.text,
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: bars,
        maxY: maxY * 1.25,
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.track, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox();
                final date = data[i]['date'] as String;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(date.substring(5),
                      style: const TextStyle(
                          color: AppColors.textTert, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: const TextStyle(
                    color: AppColors.textTert, fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String exercise;
  const _ProgressChart({required this.data, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries.map((e) {
      return FlSpot(
          e.key.toDouble(), (e.value['max_weight'] as num).toDouble());
    }).toList();

    final maxY = data.fold<double>(
        0,
        (m, d) => (d['max_weight'] as num).toDouble() > m
            ? (d['max_weight'] as num).toDouble()
            : m);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY * 1.25,
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.track, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.text,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, pct, bar, idx) =>
                  FlDotCirclePainter(
                radius: 3,
                color: AppColors.text,
                strokeWidth: 0,
                strokeColor: Colors.transparent,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.text.withValues(alpha: 0.06),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox();
                final date = data[i]['date'] as String;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(date.substring(5),
                      style: const TextStyle(
                          color: AppColors.textTert, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: const TextStyle(
                    color: AppColors.textTert, fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}
