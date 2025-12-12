import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final List<StepData> steps;
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surface.withOpacity(0.3),
                  colorScheme.surface.withOpacity(0.1),
                ]
              : [
                  Colors.white.withOpacity(0.5),
                  colorScheme.primary.withOpacity(0.02),
                ],
        ),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Row(
              children: [
                // Step Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isCompleted || isActive
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.button,
                              AppColors.button.withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isCompleted || isActive
                        ? null
                        : colorScheme.surfaceContainerHighest,
                    boxShadow: isCompleted || isActive
                        ? [
                            BoxShadow(
                              color: AppColors.button.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 22,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                // Connector Line
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? LinearGradient(
                                colors: [
                                  AppColors.button,
                                  AppColors.button.withOpacity(0.3),
                                ],
                              )
                            : null,
                        color: isCompleted
                            ? null
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class StepData {
  final String name;
  final IconData? icon;

  const StepData({
    required this.name,
    this.icon,
  });
}

