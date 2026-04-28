import 'package:flutter/material.dart';
import '../core/constants.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;
  final bool showResult;

  const OptionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.isCorrect = false,
    this.isWrong = false,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      if (showResult) {
        if (isCorrect) return AppColors.success.withOpacity(0.1);
        if (isWrong && isSelected) return AppColors.error.withOpacity(0.1);
        return AppColors.surface;
      }
      return isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface;
    }

    Color getBorderColor() {
      if (showResult) {
        if (isCorrect) return AppColors.success;
        if (isWrong && isSelected) return AppColors.error;
        return Colors.transparent;
      }
      return isSelected ? AppColors.primary : Colors.transparent;
    }

    Color getTextColor() {
      if (showResult) {
        if (isCorrect) return AppColors.success;
        if (isWrong && isSelected) return AppColors.error;
        return AppColors.textPrimary;
      }
      return isSelected ? AppColors.primary : AppColors.textPrimary;
    }

    IconData? getIcon() {
      if (showResult) {
        if (isCorrect) return Icons.check_circle;
        if (isWrong && isSelected) return Icons.cancel;
      }
      return null;
    }

    return GestureDetector(
      onTap: showResult ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: getBorderColor(),
            width: 2,
          ),
          boxShadow: [
            if (!showResult && !isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: getTextColor(),
                  fontSize: 16,
                  fontWeight: isSelected || showResult && (isCorrect || (isWrong && isSelected))
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            if (getIcon() != null)
              Icon(
                getIcon(),
                color: getTextColor(),
              ),
          ],
        ),
      ),
    );
  }
}
