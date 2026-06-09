import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';
import 'app_button.dart';

enum StatusType { loading, error, empty }

class StatusView extends StatelessWidget {
  final StatusType type;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StatusView({
    super.key,
    required this.type,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            switch (type) {
              StatusType.loading => const CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              StatusType.error => Icon(
                  Icons.error_outline_rounded,
                  size: 56.sp,
                  color: Colors.red,
                ),
              StatusType.empty => Icon(
                  Icons.article_outlined,
                  size: 56.sp,
                  color: kGrayText,
                ),
            },
            if (type != StatusType.loading) ...[
              SizedBox(height: AppSizes.spaceMd),
              Text(
                message ??
                    switch (type) {
                      StatusType.error => 'Something went wrong',
                      StatusType.empty => 'Nothing here yet',
                      StatusType.loading => '',
                    },
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15.sp,
                  color: kGrayText,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                SizedBox(height: AppSizes.spaceLg),
                SizedBox(
                  width: 160.w,
                  child: AppButton(
                    label: actionLabel!,
                    onTap: onAction,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}