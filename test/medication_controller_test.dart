import 'package:flutter_test/flutter_test.dart';
import 'package:my_medicine/data/models/medication.dart';
import 'package:my_medicine/data/repositories/medication_repository.dart';
import 'package:my_medicine/presentation/controllers/medication_controller.dart';

void main() {
  late MedicationController controller;
  late MockMedicationRepository repo;

  setUp(() {
    repo = MockMedicationRepository();
    controller = MedicationController(repo);
  });

  group('MedicationController', () {
    test('loadMedications populates list', () async {
      await controller.loadMedications();
      expect(controller.medications.isNotEmpty, true);
    });

    test('activeMeds returns only active medications', () async {
      await controller.loadMedications();
      final active = controller.activeMeds;
      expect(active.every((m) => m.status == MedicationStatus.active), true);
    });

    test('refillNeeded returns meds below threshold', () async {
      await controller.loadMedications();
      final refill = controller.refillNeeded;
      // Metformin has 8 pills, threshold 10 → should appear
      expect(refill.any((m) => m.name == 'Metformin'), true);
    });

    test('todaySchedule groups meds by time label', () async {
      await controller.loadMedications();
      final schedule = controller.todaySchedule;
      expect(schedule.containsKey('Morning'), true);
      expect(schedule.containsKey('Evening'), true);
    });

    test('deleteMedication removes from list', () async {
      await controller.loadMedications();
      final before = controller.medications.length;
      await controller.deleteMedication('med-1');
      expect(controller.medications.length, before - 1);
    });

    test('saveNewMedication adds to list', () async {
      await controller.loadMedications();
      final before = controller.medications.length;

      final form = controller.addForm;
      form.name = 'Test Drug';
      form.dosageAmount = 50;
      form.dosageUnit = 'mg';
      form.form = MedicationForm.tablet;
      form.frequency = DoseFrequency.daily;
      form.times = [const MedicationTime(label: 'Morning', time: '8:00 AM')];
      controller.updateAddForm(form);

      await controller.saveNewMedication();
      expect(controller.medications.length, before + 1);
      expect(controller.medications.last.name, 'Test Drug');
    });

    test('markDoseTaken adds taken log', () async {
      await controller.loadMedications();
      final now = DateTime.now();
      await controller.markDoseTaken('med-1', now);
      await controller.loadMedications();

      final med = controller.medications.firstWhere((m) => m.id == 'med-1');
      expect(med.logs.any((l) => l.taken), true);
    });

    test('skipDose adds skipped log', () async {
      await controller.loadMedications();
      final now = DateTime.now();
      await controller.skipDose('med-1', now);
      await controller.loadMedications();

      final med = controller.medications.firstWhere((m) => m.id == 'med-1');
      expect(med.logs.any((l) => l.skipped), true);
    });
  });

  group('Medication model', () {
    test('needsRefill is true when inventory <= threshold', () {
      const med = Medication(
        id: 'test',
        name: 'Test',
        dosageAmount: 10,
        dosageUnit: 'mg',
        form: MedicationForm.tablet,
        frequency: DoseFrequency.daily,
        times: [],
        currentInventory: 5,
        refillAt: 10,
      );
      expect(med.needsRefill, true);
    });

    test('needsRefill is false when above threshold', () {
      const med = Medication(
        id: 'test',
        name: 'Test',
        dosageAmount: 10,
        dosageUnit: 'mg',
        form: MedicationForm.tablet,
        frequency: DoseFrequency.daily,
        times: [],
        currentInventory: 30,
        refillAt: 10,
      );
      expect(med.needsRefill, false);
    });

    test('adherenceRate is 0 when no logs', () {
      const med = Medication(
        id: 'test',
        name: 'Test',
        dosageAmount: 10,
        dosageUnit: 'mg',
        form: MedicationForm.tablet,
        frequency: DoseFrequency.daily,
        times: [],
        logs: [],
      );
      expect(med.adherenceRate, 0.0);
    });
  });
}
