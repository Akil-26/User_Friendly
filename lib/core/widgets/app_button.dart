import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';

enum AppButtonType { primary, outline, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final AppButtonType type;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.type = AppButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (type) {
      AppButtonType.primary => kPrimaryColor,
      AppButtonType.outline => Colors.transparent,
      AppButtonType.danger  => Colors.transparent,
    };
    final fgColor = switch (type) {
      AppButtonType.primary => Colors.white,
      AppButtonType.outline => kPrimaryColor,
      AppButtonType.danger  => Colors.red,
    };
    final borderColor = switch (type) {
      AppButtonType.primary => kPrimaryColor,
      AppButtonType.outline => kPrimaryColor,
      AppButtonType.danger  => Colors.red,
    };

    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  color: fgColor,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18.sp, color: fgColor),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: fgColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}