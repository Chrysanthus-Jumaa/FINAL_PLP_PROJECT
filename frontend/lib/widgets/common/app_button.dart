import 'package:flutter/material.dart';
import '../../config/theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon;
  final double? width;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (type == ButtonType.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        child: Text(text),
      );
    }

    final button = type == ButtonType.secondary
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: _buildContent(),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: type == ButtonType.destructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                  )
                : null,
            child: _buildContent(),
          );

    return SizedBox(
      width: width,
      child: button,
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppTheme.sm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

enum ButtonType {
  primary,
  secondary,
  destructive,
  text,
}