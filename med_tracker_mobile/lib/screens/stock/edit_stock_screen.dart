import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/stock.dart';

class EditStockScreen extends StatefulWidget {
  final Stock stock;
  final String medicineName;

  const EditStockScreen({
    super.key,
    required this.stock,
    required this.medicineName,
  });

  @override
  State<EditStockScreen> createState() => _EditStockScreenState();
}

class _EditStockScreenState extends State<EditStockScreen> {
  late double _quantity;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantity = widget.stock.currentAmount;
    _quantityController = TextEditingController(text: _quantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateQuantity(double newQuantity) {
    if (newQuantity < 0) return;
    setState(() {
      _quantity = newQuantity;
      _quantityController.value = TextEditingValue(
        text: _quantity.toString(),
        selection: TextSelection.collapsed(offset: _quantity.toString().length),
      );
    });
  }

  Future<void> _saveChanges(FirebaseService firebaseService) async {
    try {
      if (_quantity != widget.stock.currentAmount) {
        if (_quantity > widget.stock.currentAmount) {
          final added = _quantity - widget.stock.currentAmount;
          await firebaseService.refillStock(widget.stock.medicineId, added);
        } else {
          final removed = widget.stock.currentAmount - _quantity;
          await firebaseService.decrementStock(widget.stock.medicineId, amount: removed);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Количество изменено на $_quantity ${widget.stock.unit}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicineName),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Единица измерения
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.stock.unit,
                style: TextStyle(fontSize: 18, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),

            // Количество
            const Text('Общее количество:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAdjustButton(-20, Colors.red, () => _updateQuantity(_quantity - 20)),
                const SizedBox(width: 5),
                _buildAdjustButton(-10, Colors.red, () => _updateQuantity(_quantity - 10)),
                const SizedBox(width: 5),
                _buildAdjustButton(-5, Colors.red, () => _updateQuantity(_quantity - 5)),
                const SizedBox(width: 5),
                _buildAdjustButton(-1, Colors.red, () => _updateQuantity(_quantity - 1)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Center(
                child: TextField(
                  controller: _quantityController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed >= 0) {
                      setState(() => _quantity = parsed);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAdjustButton(1, Colors.green, () => _updateQuantity(_quantity + 1)),
                const SizedBox(width: 5),
                _buildAdjustButton(5, Colors.green, () => _updateQuantity(_quantity + 5)),
                const SizedBox(width: 5),
                _buildAdjustButton(10, Colors.green, () => _updateQuantity(_quantity + 10)),
                const SizedBox(width: 5),
                _buildAdjustButton(20, Colors.green, () => _updateQuantity(_quantity + 20)),
              ],
            ),

            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Отмена', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveChanges(firebaseService),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Сохранить', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustButton(int delta, Color color, VoidCallback onPressed) {
    final isPositive = delta > 0;
    final newAmount = _quantity + delta;
    final isValid = newAmount >= 0;

    return SizedBox(
      width: 85,
      height: 50,
      child: ElevatedButton(
        onPressed: isValid ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? color.withOpacity(0.1) : color.withOpacity(0.05),
          foregroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          side: isValid ? BorderSide(color: color, width: 1) : null,
        ),
        child: Text(
          '${isPositive ? '+' : ''}$delta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isValid ? color : color.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}