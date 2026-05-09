import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

Widget buildRatingCard(
  FThemeData theme,
  double rating,
  void Function(double) onChange,
) {
  return Container(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    decoration: BoxDecoration(
      color: theme.colors.muted,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.colors.border, width: 0.8),
    ),
    child: Row(
      children: [
        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            rating.toStringAsFixed(1),
            style: theme.typography.sm.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colors.foreground,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: theme.colors.foreground,
              inactiveTrackColor: theme.colors.border,
              thumbColor: theme.colors.foreground,
              overlayColor: theme.colors.foreground.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 40,
              onChanged: (v) => onChange,
            ),
          ),
        ),
        Text(
          '/ 5',
          style: theme.typography.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    ),
  );
}
