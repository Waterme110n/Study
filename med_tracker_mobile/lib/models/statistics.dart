class DailyStat {
  final DateTime date;
  final int total;
  final int taken;
  final double percentage;

  DailyStat({
    required this.date,
    required this.total,
    required this.taken,
    required this.percentage,
  });
}

class MedicineStat {
  final String medicineId;
  final String medicineName;
  final int total;
  final int taken;
  final double percentage;

  MedicineStat({
    required this.medicineId,
    required this.medicineName,
    required this.total,
    required this.taken,
    required this.percentage,
  });
}