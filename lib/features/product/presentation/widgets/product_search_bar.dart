import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductSearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const ProductSearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou ID',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        onChanged: onSearch,
      ),
    );
  }
}
