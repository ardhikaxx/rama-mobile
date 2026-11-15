import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class LogbookStepIndicator extends StatelessWidget {
  final int currentStep;
  final Function(int) onStepTapped;

  const LogbookStepIndicator({
    super.key,
    required this.currentStep,
    required this.onStepTapped,
  });

  static const _steps = [
    {'title': 'Aktivitas', 'icon': LucideIcons.briefcase},
    {'title': 'Belajar', 'icon': LucideIcons.graduationCap},
    {'title': 'Kendala', 'icon': LucideIcons.shieldAlert},
    {'title': 'Laporan', 'icon': LucideIcons.fileCheck2},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Divider Line between steps
            final stepBefore = index ~/ 2;
            final isPassed = currentStep > stepBefore;
            return Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isPassed
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isCurrent = currentStep == stepIndex;
          final isCompleted = currentStep > stepIndex;
          final step = _steps[stepIndex];

          return InkWell(
            onTap: () {
              if (stepIndex <= currentStep) {
                onStepTapped(stepIndex);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success
                          : (isCurrent
                              ? AppColors.primary
                              : (isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9))),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.primary
                            : (isCompleted ? AppColors.success : Colors.transparent),
                        width: 2,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                          : Icon(
                              step['icon'] as IconData,
                              size: 16,
                              color: isCurrent
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['title'] as String,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent
                          ? AppColors.primary
                          : (isCompleted
                              ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
