import 'package:flutter/material.dart';

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
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Row(
              children: [
                // Step Circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? colorScheme.primary
                        : isActive
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                    border: isActive && !isCompleted
                        ? Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                // Connector Line
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(1),
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

