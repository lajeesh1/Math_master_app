import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

/// Dropdown selector for choosing question difficulty level (Low, Medium, Advanced).
class LevelDropdown extends StatelessWidget {
  final QuestionLevel selectedLevel;
  final ValueChanged<QuestionLevel> onChanged;

  const LevelDropdown({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.speed_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Question level',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                selectedLevel.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.primary.withAlpha(140),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<QuestionLevel>(
              value: selectedLevel,
              isDense: true,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: theme.colorScheme.primary,
                size: 26,
              ),
              items: QuestionLevel.values.map((level) {
                final color = _getLevelColor(level);
                return DropdownMenuItem<QuestionLevel>(
                  value: level,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        level.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newLevel) {
                if (newLevel != null) {
                  onChanged(newLevel);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(QuestionLevel level) {
    switch (level) {
      case QuestionLevel.low:
        return Colors.green.shade700;
      case QuestionLevel.medium:
        return Colors.orange.shade800;
      case QuestionLevel.advanced:
        return Colors.deepPurple.shade700;
    }
  }
}
