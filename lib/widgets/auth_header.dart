import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;

  const AuthHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 220,
      alignment: Alignment.center,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineLarge?.copyWith(color: colors.onPrimary),
      ),
    );
  }
}
