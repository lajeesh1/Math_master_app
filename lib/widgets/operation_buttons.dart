import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

/// Clean, responsive interactive button selector for choosing the quiz question type.
class OperationButtons extends StatelessWidget {
  final QuizOperation? selectedOperation;
  final ValueChanged<QuizOperation> onSelected;

  const OperationButtons({
    super.key,
    required this.selectedOperation,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calculate_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Question Type',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Select one operation to practice',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildOperationTile(QuizOperation.multiplication, theme)),
            const SizedBox(width: 10),
            Expanded(child: _buildOperationTile(QuizOperation.addition, theme)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildOperationTile(QuizOperation.subtraction, theme)),
            const SizedBox(width: 10),
            Expanded(child: _buildOperationTile(QuizOperation.division, theme)),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationTile(QuizOperation operation, ThemeData theme) {
    final isSelected = selectedOperation == operation;
    final color = _getOperationColor(operation);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(operation),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(28) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2.2 : 1.2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: color.withAlpha(45),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withAlpha(isSelected ? 55 : 25),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  operation.symbol,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    operation.shortName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? color : theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle_rounded,
                  size: 17,
                  color: color,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getOperationColor(QuizOperation op) {
    switch (op) {
      case QuizOperation.multiplication:
        return Colors.indigo.shade700;
      case QuizOperation.addition:
        return Colors.teal.shade700;
      case QuizOperation.subtraction:
        return Colors.deepOrange.shade700;
      case QuizOperation.division:
        return Colors.purple.shade700;
    }
  }
}
