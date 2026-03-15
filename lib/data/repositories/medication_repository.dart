import 'package:uuid/uuid.dart';

import '../models/medication.dart';

abstract class MedicationRepository {
  Future<List<Medication>> getAll();
  Future<Medication?> getById(String id);
  Future<void> add(Medication medication);
  Future<void> update(Medication medication);
  Future<void> delete(String id);
  Future<void> logDose(String medicationId, DoseLog log);
}

class MockMedicationRepository implements MedicationRepository {
  final _uuid = const Uuid();

  final List<Medication> _store = [
    Medication(
      id: 'med-1',
      name: 'Lisinopril',
      dosageAmount: 10,
      dosageUnit: 'mg',
      form: MedicationForm.tablet,
      frequency: DoseFrequency.twiceDaily,
      times: [
        MedicationTime(label: 'Morning', time: '8:00 AM'),
        MedicationTime(label: 'Evening', time: '8:00 PM'),
      ],
      status: MedicationStatus.active,
      colorHex: '#FFFFFF',
      shape: 'round',
      currentInventory: 30,
      refillAt: 10,
      logs: [],
    ),
    Medication(
      id: 'med-2',
      name: 'Metformin',
      dosageAmount: 500,
      dosageUnit: 'mg',
      form: MedicationForm.tablet,
      frequency: DoseFrequency.twiceDaily,
      times: [
        MedicationTime(label: 'Morning', time: '8:00 AM'),
        MedicationTime(label: 'Evening', time: '8:00 PM'),
      ],
      status: MedicationStatus.active,
      colorHex: '#F5F5DC',
      shape: 'oval',
      currentInventory: 8,
      refillAt: 10,
      logs: [],
    ),
    Medication(
      id: 'med-3',
      name: 'Atorvastatin',
      dosageAmount: 20,
      dosageUnit: 'mg',
      form: MedicationForm.tablet,
      frequency: DoseFrequency.daily,
      times: [MedicationTime(label: 'Evening', time: '8:00 PM')],
      status: MedicationStatus.active,
      colorHex: '#E8D5B7',
      shape: 'oval',
      currentInventory: 45,
      refillAt: 10,
      logs: [],
    ),
    Medication(
      id: 'med-4',
      name: 'Vitamin D',
      dosageAmount: 1000,
      dosageUnit: 'IU',
      form: MedicationForm.capsule,
      frequency: DoseFrequency.daily,
      times: [MedicationTime(label: 'Afternoon', time: '1:00 PM')],
      status: MedicationStatus.active,
      colorHex: '#FFD700',
      shape: 'round',
      currentInventory: 60,
      refillAt: 10,
      logs: [],
    ),
    Medication(
      id: 'med-5',
      name: 'Ibuprofen',
      dosageAmount: 200,
      dosageUnit: 'mg',
      form: MedicationForm.tablet,
      frequency: DoseFrequency.asNeeded,
      times: [],
      status: MedicationStatus.asNeeded,
      colorHex: '#FF4500',
      shape: 'round',
      currentInventory: 20,
      refillAt: 5,
      logs: [],
    ),
  ];

  @override
  Future<List<Medication>> getAll() async => List.unmodifiable(_store);

  @override
  Future<Medication?> getById(String id) async =>
      _store.where((m) => m.id == id).firstOrNull;

  @override
  Future<void> add(Medication medication) async {
    _store.add(medication);
  }

  @override
  Future<void> update(Medication medication) async {
    final idx = _store.indexWhere((m) => m.id == medication.id);
    if (idx != -1) _store[idx] = medication;
  }

  @override
  Future<void> delete(String id) async {
    _store.removeWhere((m) => m.id == id);
  }

  @override
  Future<void> logDose(String medicationId, DoseLog log) async {
    final idx = _store.indexWhere((m) => m.id == medicationId);
    if (idx != -1) {
      final med = _store[idx];
      _store[idx] = med.copyWith(logs: [...med.logs, log]);
    }
  }

  String generateId() => _uuid.v4();
}
