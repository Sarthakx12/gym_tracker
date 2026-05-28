import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActivityDots extends StatelessWidget {
  final List<DateTime> activeDates;
  final int monthCount;

  const ActivityDots({
    super.key,
    required this.activeDates,
    this.monthCount = 3,
  });

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  bool _isActive(DateTime date) => activeDates.any((d) =>
    d.year == date.year && d.month == date.month && d.day == date.day);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startMonth = DateTime(now.year, now.month - (monthCount - 1), 1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(monthCount, (mi) {
        final month = DateTime(startMonth.year, startMonth.month + mi, 1);
        final daysInMonth =
            DateTime(month.year, month.month + 1, 0).day;

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _months[month.month - 1],
                style: const TextStyle(
                  color: AppColors.textSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 3,
                runSpacing: 3,
                children: List.generate(daysInMonth, (day) {
                  final date = DateTime(month.year, month.month, day + 1);
                  final isActive = _isActive(date);
                  final isFuture = date.isAfter(now);
                  final isToday = date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;

                  return Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.accent
                          : isFuture
                              ? Colors.transparent
                              : AppColors.track,
                      shape: BoxShape.circle,
                      boxShadow: isToday && isActive
                          ? [BoxShadow(
                              color: Colors.white.withValues(alpha: 0.6),
                              blurRadius: 4,
                            )]
                          : null,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}
