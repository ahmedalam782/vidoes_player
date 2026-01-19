import 'package:flutter/material.dart';
import 'app_strings.dart';

extension TextStyleExtension on num {
  TextStyle get bold => TextStyle(
    fontSize: toDouble(),
    fontWeight: FontWeight.w700,
    fontFamily: AppStrings.arabicFontFamily,
  );

  TextStyle get semiBold => TextStyle(
    fontSize: toDouble(),
    fontWeight: FontWeight.w600,
    fontFamily: AppStrings.arabicFontFamily,
  );

  TextStyle get medium => TextStyle(
    fontSize: toDouble(),
    fontWeight: FontWeight.w500,
    fontFamily: AppStrings.arabicFontFamily,
  );

  TextStyle get regular => TextStyle(
    fontSize: toDouble(),
    fontWeight: FontWeight.w400,
    fontFamily: AppStrings.arabicFontFamily,
  );

  TextStyle get light => TextStyle(
    fontSize: toDouble(),
    fontWeight: FontWeight.w300,
    fontFamily: AppStrings.arabicFontFamily,
  );

  TextStyle get extraLight => TextStyle(
    fontSize: toDouble(),
    fontWeight: FontWeight.w200,
    fontFamily: AppStrings.arabicFontFamily,
  );
}
