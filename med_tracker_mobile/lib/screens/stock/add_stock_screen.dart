import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/medicine.dart';
import '../../models/stock.dart';
import '../drugs/add_medicine_screen.dart';

class AddToStockScreen extends StatefulWidget {
  final Medicine? initialMedicine;

  const AddToStockScreen({super.key, this.initialMedicine});

  @override
  State<AddToStockScreen> createState() => _AddToStockScreenState();
}

class _AddToStockScreenState extends State<AddToStockScreen> {
  Medicine? _selectedMedicine;
  double _quantity = 1;
  String _unit = 'мг';

  // Для поиска
  final TextEditingController _searchController = TextEditingController();
  List<Medicine> _searchResults = [];
  bool _isSearching = false;

  // Контроллер для поля количества
  late TextEditingController _quantityController;

  // Единицы измерения
  final List<String> _units = [
    'мг',
    'мл',
    'шт',
    'капсулы',
    'капли',
    'таблетки'
  ];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: _quantity.toString());

    if (widget.initialMedicine != null) {
      _selectedMedicine = widget.initialMedicine;
      _updateQuantityController();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _updateQuantityController() {
    _quantityController.value = TextEditingValue(
      text: _quantity.toString(),
      selection: TextSelection.collapsed(offset: _quantity.toString().length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedMedicine == null ? 'Добавить в аптечку' : _selectedMedicine!.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: _selectedMedicine != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedMedicine = null;
              _searchController.clear();
              _searchResults.clear();
            });
          },
        )
            : null,
      ),
      body: _selectedMedicine == null
          ? _buildMedicineSearch()
          : _buildQuantityForm(),
    );
  }

  Widget _buildMedicineSearch() {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Введите название лекарства...',
              prefixIcon: const Icon(Icons.search, color: Colors.blue),
              suffixIcon: _isSearching
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            onChanged: (value) async {
              if (value.isNotEmpty) {
                setState(() => _isSearching = true);
                final results = await firebaseService.searchMedicines(value);
                setState(() {
                  _searchResults = results;
                  _isSearching = false;
                });
              } else {
                setState(() {
                  _searchResults = [];
                });
              }
            },
          ),
        ),

        if (_searchResults.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final medicine = _searchResults[index];
                final isPersonal = medicine.isPersonal ?? false;

                return FutureBuilder<List<Stock>>(
                  future: firebaseService.getStocks().first,
                  builder: (context, snapshot) {
                    // Проверяем, есть ли уже это лекарство в аптечке с КАКОЙ-ЛИБО единицей
                    final existingStocks = snapshot.data ?? [];
                    final existingUnits = existingStocks
                        .where((s) => s.medicineId == medicine.id)
                        .map((s) => s.unit)
                        .toList();

                    final isInStockAny = existingUnits.isNotEmpty;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPersonal ? Colors.green.shade100 : Colors.blue.shade100,
                          child: Icon(
                            isPersonal ? Icons.person : Icons.medication,
                            color: isPersonal ? Colors.green : Colors.blue,
                          ),
                        ),
                        title: Text(
                          medicine.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isInStockAny ? Colors.black87 : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (medicine.genericName != null && medicine.genericName!.isNotEmpty)
                              Text(
                                medicine.genericName!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (existingUnits.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: existingUnits.map((unit) => Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    unit,
                                    style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                                  ),
                                )).toList(),
                              ),
                          ],
                        ),
                        trailing: isPersonal
                            ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Моё', style: TextStyle(fontSize: 10, color: Colors.green.shade800)),
                        )
                            : const Icon(Icons.add, color: Colors.blue),
                        onTap: () {
                          setState(() {
                            _selectedMedicine = medicine;
                            _searchController.clear();
                            _searchResults.clear();
                            _updateQuantityController();
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

        if (_isSearching)
          const Expanded(child: Center(child: CircularProgressIndicator())),

        if (!_isSearching && _searchResults.isEmpty && _searchController.text.length >= 2)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Ничего не найдено',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Попробуйте изменить запрос или добавьте новое лекарство',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
                      );
                      if (result != null && result is Medicine) {
                        setState(() {
                          _selectedMedicine = result;
                          _searchController.clear();
                          _searchResults.clear();
                          _updateQuantityController();
                        });
                      }
                    },
                    icon: const Icon(Icons.add_box),
                    label: const Text('Добавить новое лекарство'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (_searchController.text.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Начните вводить название лекарства',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
                      );
                      if (result != null && result is Medicine) {
                        setState(() {
                          _selectedMedicine = result;
                          _searchController.clear();
                          _searchResults.clear();
                          _updateQuantityController();
                        });
                      }
                    },
                    icon: const Icon(Icons.add_box),
                    label: const Text('Добавить новое лекарство'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuantityForm() {
    final medicine = _selectedMedicine!;
    final firebaseService = Provider.of<FirebaseService>(context);

    return FutureBuilder<List<Stock>>(
      future: firebaseService.getStocks().first,
      builder: (context, snapshot) {
        final existingStocks = snapshot.data ?? [];
        // Проверяем, есть ли это лекарство с такой же единицей измерения
        final existingWithSameUnit = existingStocks.any(
                (s) => s.medicineId == medicine.id && s.unit == _unit
        );

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.medication, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(medicine.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          if (medicine.genericName != null && medicine.genericName!.isNotEmpty)
                            Text(medicine.genericName!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                value: _unit,
                decoration: const InputDecoration(
                  labelText: 'Единица измерения',
                  border: OutlineInputBorder(),
                ),
                items: _units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _unit = value);
                },
              ),

              // Показываем предупреждение, если такая единица уже есть
              if (existingWithSameUnit)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Лекарство в такой единице уже есть в аптечке. Вы можете добавить ещё одну партию в существующую запись через редактирование.',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              const Text('Общее количество:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuantityButton(Icons.remove, () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                        _updateQuantityController();
                      });
                    }
                  }, 48),
                  Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _quantityController,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          setState(() => _quantity = parsed);
                        }
                      },
                    ),
                  ),
                  _buildQuantityButton(Icons.add, () {
                    setState(() {
                      _quantity++;
                      _updateQuantityController();
                    });
                  }, 48),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: existingWithSameUnit ? null : _saveToStock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: existingWithSameUnit ? Colors.grey : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Добавить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed, double size) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(icon, color: Colors.blue.shade700, size: 24),
      ),
    );
  }

  Future<void> _saveToStock() async {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    final medicine = _selectedMedicine!;

    try {
      await firebaseService.upsertStock(
        medicineId: medicine.id!,
        amount: _quantity,
        unit: _unit,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medicine.name} ($_unit) добавлено в аптечку'),
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
}