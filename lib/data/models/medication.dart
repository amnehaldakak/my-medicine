import 'package:equatable/equatable.dart';

enum MedicationStatus { active, paused, asNeeded }
enum MedicationForm { tablet, capsule, liquid, injection, patch, other }
enum DoseFrequency { daily, twiceDaily, threeTimesDaily, weekly, asNeeded }

class MedicationTime {
  final String label; // "Morning", "Afternoon", "Evening"
  final String time;  // "08:00 AM"

  const MedicationTime({required this.label, required this.time});

  Map<String, dynamic> toMap() => {'label': label, 'time': time};
  factory MedicationTime.fromMap(Map<String, dynamic> m) =>
      MedicationTime(label: m['label'], time: m['time']);
}

class DoseLog {
  final DateTime scheduledAt;
  final DateTime? takenAt;
  final bool skipped;

  const DoseLog({
    required this.scheduledAt,
    this.takenAt,
    this.skipped = false,
  });

  bool get taken => takenAt != null && !skipped;
}

class Medication extends Equatable {
  final String id;
  final String name;
  final double dosageAmount;
  final String dosageUnit; // "mg", "ml", etc.
  final MedicationForm form;
  final DoseFrequency frequency;
  final List<MedicationTime> times;
  final MedicationStatus status;
  final String? colorHex;    // pill color
  final String? shape;       // "round", "oval"
  final int? currentInventory;
  final int? refillAt;       // threshold to show refill warning
  final String? notes;
  final List<DoseLog> logs;

  const Medication({
    required this.id,
    required this.name,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.form,
    required this.frequency,
    required this.times,
    this.status = MedicationStatus.active,
    this.colorHex,
    this.shape,
    this.currentInventory,
    this.refillAt,
    this.notes,
    this.logs = const [],
  });

  Medication copyWith({
    String? name,
    double? dosageAmount,
    String? dosageUnit,
    MedicationForm? form,
    DoseFrequency? frequency,
    List<MedicationTime>? times,
    MedicationStatus? status,
    String? colorHex,
    String? shape,
    int? currentInventory,
    int? refillAt,
    String? notes,
    List<DoseLog>? logs,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      dosageAmount: dosageAmount ?? this.dosageAmount,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      form: form ?? this.form,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      status: status ?? this.status,
      colorHex: colorHex ?? this.colorHex,
      shape: shape ?? this.shape,
      currentInventory: currentInventory ?? this.currentInventory,
      refillAt: refillAt ?? this.refillAt,
      notes: notes ?? this.notes,
      logs: logs ?? this.logs,
    );
  }

  /// Adherence percentage over last 30 days (0.0 – 1.0)
  double get adherenceRate {
    if (logs.isEmpty) return 0;
    final taken = logs.where((l) => l.taken).length;
    return taken / logs.length;
  }

  bool get needsRefill =>
      currentInventory != null &&
      refillAt != null &&
      currentInventory! <= refillAt!;

  @override
  List<Object?> get props => [id, name, dosageAmount, dosageUnit, status];
}

// --------------- Add-Med wizard state ---------------
class AddMedicationForm {
  String name;
  double? dosageAmount;
  String dosageUnit;
  MedicationForm? form;
  DoseFrequency? frequency;
  List<MedicationTime> times;
  String? colorHex;
  String? shape;
  int? currentInventory;
  int? refillAt;

  AddMedicationForm({
    this.name = '',
    this.dosageAmount,
    this.dosageUnit = 'mg',
    this.form,
    this.frequency,
    this.times = const [],
    this.colorHex,
    this.shape,
    this.currentInventory,
    this.refillAt,
  });
}
