import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  final FThemeData theme;

  const SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: theme.typography.xs.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colors.mutedForeground,
        letterSpacing: 1.1,
      ),
    );
  }
}
