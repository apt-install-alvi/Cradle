import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final double width;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: width,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSecondary ? null : AppTheme.tealGradient,
          color: isSecondary ? Colors.transparent : null,
          border: isSecondary 
              ? Border.all(
                  color: isDark ? AppTheme.primaryLightTeal : AppTheme.primaryTeal, 
                  width: 2
                ) 
              : null,
          boxShadow: isSecondary ? null : [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: isSecondary 
                        ? (isDark ? AppTheme.primaryLightTeal : AppTheme.primaryTeal) 
                        : Colors.white, 
                    strokeWidth: 2.5
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSecondary 
                        ? (isDark ? AppTheme.primaryLightTeal : AppTheme.primaryTeal) 
                        : Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}


