import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

/// A child-friendly dropdown selector for choosing the quiz operation.
class OperationDropdown extends StatelessWidget {
  final QuizOperation? selectedOperation;
  final ValueChanged<QuizOperation?> onChanged;

  const OperationDropdown({
    super.key,
    required this.selectedOperation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calculate_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Choose Question Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withAlpha(128),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<QuizOperation>(
              isExpanded: true,
              value: selectedOperation,
              hint: Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Select an operation...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              icon: Icon(
                Icons.arrow_drop_down_circle_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              items: QuizOperation.values.map((operation) {
                return DropdownMenuItem<QuizOperation>(
                  value: operation,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _getOperationColor(operation).withAlpha(38),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          operation.symbol,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _getOperationColor(operation),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        operation.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Color _getOperationColor(QuizOperation op) {
    switch (op) {
      case QuizOperation.multiplication:
        return Colors.indigo;
      case QuizOperation.addition:
        return Colors.teal;
      case QuizOperation.subtraction:
        return Colors.deepOrange;
      case QuizOperation.division:
        return Colors.purple;
    }
  }
}
