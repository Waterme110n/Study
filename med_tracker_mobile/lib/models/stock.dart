// lib/models/stock.dart
class Stock {
  final String stockId;
  final String medicineId;
  final double currentAmount;
  final String unit;

  Stock({
    required this.stockId,
    required this.medicineId,
    required this.currentAmount,
    required this.unit,
  });

  factory Stock.fromMap(String id, Map<String, dynamic> data) {
    return Stock(
      stockId: id,
      medicineId: data['medicineId'] as String? ?? '',
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] as String? ?? 'мг',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'currentAmount': currentAmount,
      'unit': unit,
    };
  }
}