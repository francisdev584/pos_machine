import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/theme/app_theme.dart';

class MainButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const MainButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: isPrimary ? 4 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: isPrimary ? AppTheme.primaryColor : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(12.r),
            color: isPrimary ? AppTheme.primaryColor : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color:
                      isPrimary
                          ? Colors.white.withAlpha(26)
                          : AppTheme.primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : AppTheme.primaryColor,
                  size: 48.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPrimary ? Colors.white : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isPrimary ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24.w,
                color: isPrimary ? Colors.white70 : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
