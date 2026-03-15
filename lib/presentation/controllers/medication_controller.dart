import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/medication.dart';
import '../../data/repositories/medication_repository.dart';

class MedicationController extends ChangeNotifier {
  final MedicationRepository _repo;
  final _uuid = const Uuid();

  List<Medication> _medications = [];
  bool _loading = false;
  String? _error;

  // Add-med wizard state
  AddMedicationForm _addForm = AddMedicationForm();

  MedicationController(this._repo);

  List<Medication> get medications => _medications;
  bool get loading => _loading;
  String? get error => _error;
  AddMedicationForm get addForm => _addForm;

  List<Medication> get activeMeds =>
      _medications.where((m) => m.status == MedicationStatus.active).toList();
  List<Medication> get pausedMeds =>
      _medications.where((m) => m.status == MedicationStatus.paused).toList();
  List<Medication> get asNeededMeds =>
      _medications.where((m) => m.status == MedicationStatus.asNeeded).toList();
  List<Medication> get refillNeeded =>
      _medications.where((m) => m.needsRefill).toList();

  /// Medications scheduled for today, grouped by time label
  Map<String, List<Medication>> get todaySchedule {
    final schedule = <String, List<Medication>>{};
    for (final med in activeMeds) {
      for (final t in med.times) {
        schedule.putIfAbsent(t.label, () => []).add(med);
      }
    }
    return schedule;
  }

  Future<void> loadMedications() async {
    _loading = true;
    notifyListeners();
    try {
      _medications = await _repo.getAll();
      _loading = false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
    }
    notifyListeners();
  }

  Future<Medication?> getMedication(String id) => _repo.getById(id);

  Future<void> deleteMedication(String id) async {
    await _repo.delete(id);
    _medications.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Future<void> updateStatus(String id, MedicationStatus status) async {
    final med = _medications.firstWhere((m) => m.id == id);
    final updated = med.copyWith(status: status);
    await _repo.update(updated);
    final idx = _medications.indexWhere((m) => m.id == id);
    _medications[idx] = updated;
    notifyListeners();
  }

  Future<void> markDoseTaken(String medId, DateTime scheduledAt) async {
    final log = DoseLog(
      scheduledAt: scheduledAt,
      takenAt: DateTime.now(),
    );
    await _repo.logDose(medId, log);
    await loadMedications();
  }

  Future<void> skipDose(String medId, DateTime scheduledAt) async {
    final log = DoseLog(scheduledAt: scheduledAt, skipped: true);
    await _repo.logDose(medId, log);
    await loadMedications();
  }

  // --------------- Add-med wizard ---------------
  void resetAddForm() {
    _addForm = AddMedicationForm();
    notifyListeners();
  }

  void updateAddForm(AddMedicationForm form) {
    _addForm = form;
    notifyListeners();
  }

  Future<void> saveNewMedication() async {
    final form = _addForm;
    final med = Medication(
      id: _uuid.v4(),
      name: form.name,
      dosageAmount: form.dosageAmount ?? 0,
      dosageUnit: form.dosageUnit,
      form: form.form ?? MedicationForm.tablet,
      frequency: form.frequency ?? DoseFrequency.daily,
      times: form.times,
      colorHex: form.colorHex,
      shape: form.shape,
      currentInventory: form.currentInventory,
      refillAt: form.refillAt,
    );
    await _repo.add(med);
    _medications.add(med);
    resetAddForm();
    notifyListeners();
  }
}
