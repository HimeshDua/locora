import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AuthTextField extends StatefulWidget {
  final String hint;
  final List<List<dynamic>> icon;
  final bool obscure;
  final TextEditingController? controller;
  final String? errorText;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.errorText,
    this.obscure = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Focus(
      onFocusChange: (value) {
        setState(() => isFocused = value);
      },
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscure,
        style: text.bodyMedium?.copyWith(color: colors.onSurface),
        cursorColor: colors.primary,
        decoration: InputDecoration(
          hintText: widget.hint,
          errorText: widget.errorText,
          hintStyle: text.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(0.5),
          ),

          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: HugeIcon(
              icon: widget.icon,
              size: 20,
              color: isFocused
                  ? colors.primary
                  : colors.onSurface.withOpacity(0.6),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),

          filled: true,
          fillColor: colors.surface.withOpacity(0.6),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.outline.withOpacity(0.2)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
