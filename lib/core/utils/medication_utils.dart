import '../../data/models/medication.dart';
import '../constants/app_colors.dart';
import 'package:flutter/material.dart';

class MedicationUtils {
  static String frequencyLabel(DoseFrequency f) {
    switch (f) {
      case DoseFrequency.daily:
        return 'Once daily';
      case DoseFrequency.twiceDaily:
        return 'Twice daily';
      case DoseFrequency.threeTimesDaily:
        return '3× daily';
      case DoseFrequency.weekly:
        return 'Weekly';
      case DoseFrequency.asNeeded:
        return 'As needed';
    }
  }

  static String formLabel(MedicationForm f) {
    switch (f) {
      case MedicationForm.tablet:
        return 'Tablet';
      case MedicationForm.capsule:
        return 'Capsule';
      case MedicationForm.liquid:
        return 'Liquid';
      case MedicationForm.injection:
        return 'Injection';
      case MedicationForm.patch:
        return 'Patch';
      case MedicationForm.other:
        return 'Other';
    }
  }

  static String statusLabel(MedicationStatus s) {
    switch (s) {
      case MedicationStatus.active:
        return 'Active';
      case MedicationStatus.paused:
        return 'Paused';
      case MedicationStatus.asNeeded:
        return 'As Needed';
    }
  }

  static Color statusColor(MedicationStatus s) {
    switch (s) {
      case MedicationStatus.active:
        return AppColors.success;
      case MedicationStatus.paused:
        return AppColors.warning;
      case MedicationStatus.asNeeded:
        return AppColors.primaryLight;
    }
  }

  static Color pillColor(String? hex) {
    if (hex == null) return AppColors.primaryLight;
    try {
      return Color(
          int.parse(hex.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (_) {
      return AppColors.primaryLight;
    }
  }

  static IconData formIcon(MedicationForm f) {
    switch (f) {
      case MedicationForm.tablet:
        return Icons.circle_outlined;
      case MedicationForm.capsule:
        return Icons.medication_outlined;
      case MedicationForm.liquid:
        return Icons.water_drop_outlined;
      case MedicationForm.injection:
        return Icons.colorize_outlined;
      case MedicationForm.patch:
        return Icons.square_outlined;
      case MedicationForm.other:
        return Icons.more_horiz;
    }
  }

  static Color adherenceColor(double rate) {
    if (rate >= 0.9) return AppColors.success;
    if (rate >= 0.6) return AppColors.primaryLight;
    if (rate >= 0.3) return AppColors.warning;
    return AppColors.error;
  }
}
