import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/firebase_service.dart';
import '../../services/notification_service.dart';
import '../../services/statistics_service.dart';
import '../../models/statistics.dart';
import 'package:flutter/services.dart';
import '../../services/firebase_service.dart';
import '../auth/login_screen.dart';
import '../drugs/medicines_screen.dart';
import '../home/home_screen.dart';
import '../stock/stock_screen.dart';

class GroupedDailyStat {
  final String shortLabel;
  final String tooltipLabel;
  final int total;
  final int taken;
  final double percentage;
  final DateTime startDate;
  final DateTime endDate;

  GroupedDailyStat({
    required this.shortLabel,
    required this.tooltipLabel,
    required this.total,
    required this.taken,
    required this.percentage,
    required this.startDate,
    required this.endDate,
  });
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

enum Period { week, month, custom }

class _StatisticsScreenState extends State<StatisticsScreen> {
  Period _selectedPeriod = Period.week;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  bool _isLoading = false;
  Map<String, dynamic>? _statistics;

  late StatisticsService _statisticsService;

  @override
  void initState() {
    super.initState();
    _statisticsService = StatisticsService(
      Provider.of<FirebaseService>(context, listen: false),
    );

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    _startDate = yesterday.subtract(const Duration(days: 6));
    _endDate = yesterday;

    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _statisticsService.getStatistics(_startDate, _endDate);
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveToDownloads() async {
    if (_statistics == null) return;

    // Загружаем шрифт
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final dailyStats = _statistics!['dailyStats'] as List<DailyStat>;
    final medicineStats = _statistics!['medicineStats'] as List<MedicineStat>;
    final total = _statistics!['total'] as int;
    final taken = _statistics!['taken'] as int;
    final overallPercentage = _statistics!['overallPercentage'] as double;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Отчёт о приёме лекарств',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Период: ${DateFormat('dd.MM.yyyy').format(_startDate)} - ${DateFormat('dd.MM.yyyy').format(_endDate)}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey, font: ttf),
          ),
          pw.SizedBox(height: 30),

          pw.Header(level: 1, child: pw.Text('Общая статистика', style: pw.TextStyle(font: ttf))),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('Выполнено', '$taken / $total', '${overallPercentage.toStringAsFixed(1)}%', ttf),
            ],
          ),

          pw.SizedBox(height: 30),

          pw.Header(level: 1, child: pw.Text('По лекарствам', style: pw.TextStyle(font: ttf))),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Лекарство', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Выполнено', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Процент', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf))),
                ],
              ),
              for (final stat in medicineStats)
                pw.TableRow(
                  children: [
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(stat.medicineName, style: pw.TextStyle(font: ttf))),
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('${stat.taken} / ${stat.total}', style: pw.TextStyle(font: ttf))),
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('${stat.percentage.toStringAsFixed(1)}%', style: pw.TextStyle(font: ttf))),
                  ],
                ),
            ],
          ),

          pw.SizedBox(height: 30),

          pw.Header(level: 1, child: pw.Text('По дням', style: pw.TextStyle(font: ttf))),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Дата', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Выполнено', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Процент', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf))),
                ],
              ),
              for (final stat in dailyStats)
                if (stat.total > 0)
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(DateFormat('dd.MM').format(stat.date), style: pw.TextStyle(font: ttf))),
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('${stat.taken} / ${stat.total}', style: pw.TextStyle(font: ttf))),
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('${stat.percentage.toStringAsFixed(1)}%', style: pw.TextStyle(font: ttf))),
                    ],
                  ),
            ],
          ),

          pw.SizedBox(height: 30),
          pw.Text(
            'Отчёт сгенерирован ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey, font: ttf),
          ),
        ],
      ),
    );
    // Сохраняем в папку "Загрузки"
    Directory? downloadDir;

    // Пробуем разные пути для Android
    if (Platform.isAndroid) {
      try {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          downloadDir = Directory('/sdcard/Download');
        }
        if (!await downloadDir.exists()) {
          downloadDir = Directory('/data/media/0/Download');
        }
      } catch (e) {
        print('Ошибка пути: $e');
      }
    }

    // Fallback через path_provider
    if (downloadDir == null || !await downloadDir.exists()) {
      downloadDir = await getDownloadsDirectory();
    }

    if (downloadDir == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось получить доступ к папке загрузок'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'medication_report_$dateStr.pdf';
    final file = File('${downloadDir.path}/$fileName');

    await file.writeAsBytes(await pdf.save());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Сохранено: ${downloadDir.path}/$fileName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _sharePDF() async {
    if (_statistics == null) return;

    final dailyStats = _statistics!['dailyStats'] as List<DailyStat>;
    final medicineStats = _statistics!['medicineStats'] as List<MedicineStat>;
    final total = _statistics!['total'] as int;
    final taken = _statistics!['taken'] as int;
    final overallPercentage = _statistics!['overallPercentage'] as double;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Отчёт о приёме лекарств',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Период: ${DateFormat('dd.MM.yyyy').format(_startDate)} - ${DateFormat('dd.MM.yyyy').format(_endDate)}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 30),

          pw.Header(level: 1, child: pw.Text('Общая статистика')),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCardNoFont('Выполнено', '$taken / $total', '${overallPercentage.toStringAsFixed(1)}%'),
            ],
          ),

          pw.SizedBox(height: 30),

          pw.Header(level: 1, child: pw.Text('По лекарствам')),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Лекарство', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Выполнено', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Процент', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),
              for (final stat in medicineStats)
                pw.TableRow(
                  children: [
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(stat.medicineName)),
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('${stat.taken} / ${stat.total}')),
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('${stat.percentage.toStringAsFixed(1)}%')),
                  ],
                ),
            ],
          ),

          pw.SizedBox(height: 30),

          pw.Header(level: 1, child: pw.Text('По дням')),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Дата', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Выполнено', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Процент', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),
              for (final stat in dailyStats)
                if (stat.total > 0)
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(DateFormat('dd.MM').format(stat.date))),
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('${stat.taken} / ${stat.total}')),
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('${stat.percentage.toStringAsFixed(1)}%')),
                    ],
                  ),
            ],
          ),

          pw.SizedBox(height: 30),
          pw.Text(
            'Отчёт сгенерирован ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ],
      ),
    );

    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'medication_report_$dateStr.pdf';

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: fileName,
    );
  }

  pw.Widget _buildStatCardNoFont(String title, String value, String subtitle) {
    return pw.Container(
      width: 150,
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
          pw.SizedBox(height: 8),
          pw.Text(value, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(subtitle, style: pw.TextStyle(fontSize: 14, color: PdfColors.blue)),
        ],
      ),
    );
  }

  void _updatePeriod(Period period) {
    setState(() {
      _selectedPeriod = period;
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));

      switch (period) {
        case Period.week:
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          _startDate = yesterday.subtract(const Duration(days: 6));
          _endDate = yesterday;
          break;
        case Period.month:
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          _startDate = yesterday.subtract(const Duration(days: 29));
          _endDate = yesterday;
          break;
        case Period.custom:
          break;
      }
    });
    _loadStatistics();
  }

  Future<void> _selectCustomDates() async {
    final DateTime? start = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ru', 'RU'),
    );

    if (start != null) {
      final DateTime? end = await showDatePicker(
        context: context,
        initialDate: _endDate,
        firstDate: start,
        lastDate: DateTime.now(),
        locale: const Locale('ru', 'RU'),
      );

      if (end != null) {
        setState(() {
          _startDate = start;
          _endDate = end;
          _selectedPeriod = Period.custom;
        });
        _loadStatistics();
      }
    }
  }

  pw.Widget _buildStatCard(String title, String value, String subtitle, pw.Font ttf) {
    return pw.Container(
      width: 150,
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey, font: ttf)),
          pw.SizedBox(height: 8),
          pw.Text(value, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf)),
          pw.SizedBox(height: 4),
          pw.Text(subtitle, style: pw.TextStyle(fontSize: 14, color: PdfColors.blue, font: ttf)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _statistics != null ? _saveToDownloads : null,
            tooltip: 'Сохранить PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _statistics != null ? _sharePDF : null,
            tooltip: 'Поделиться',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF36A5E5), Colors.blueAccent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/icons/taking_medications.png',
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Taking Medications',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ваш помощник в приёме лекарств',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.medication, color: Colors.grey),
              title: const Text('Мои лекарства'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books, color: Colors.grey),
              title: const Text('Все лекарства'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicinesCatalogScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.grey),
              title: const Text('В наличии'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StockScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.blue),
              title: const Text('Статистика', style: TextStyle(fontWeight: FontWeight.w500)),
              selected: true,
              selectedTileColor: Colors.blue.shade50,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Выход', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await NotificationService().cancelAllNotifications();
                final firebaseService = Provider.of<FirebaseService>(context, listen: false);
                await firebaseService.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPeriodButton('Неделя', Period.week),
                _buildPeriodButton('Месяц', Period.month),
                _buildPeriodButton('Произвольный', Period.custom, onTap: _selectCustomDates),
              ],
            ),
          ),

          if (_selectedPeriod == Period.custom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${DateFormat('dd.MM.yyyy').format(_startDate)} - ${DateFormat('dd.MM.yyyy').format(_endDate)}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, size: 20),
                    onPressed: _selectCustomDates,
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _statistics == null
                ? const Center(child: Text('Нет данных за выбранный период'))
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOverallStats(),
                  const SizedBox(height: 24),
                  _buildDailyChart(),
                  const SizedBox(height: 24),
                  _buildMedicineStats(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String title, Period period, {VoidCallback? onTap}) {
    final isSelected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: onTap ?? () => _updatePeriod(period),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStats() {
    final total = _statistics!['total'];
    final taken = _statistics!['taken'];
    final percentage = _statistics!['overallPercentage'];

    final totalInt = total is int ? total : (total as num).toInt();
    final takenInt = taken is int ? taken : (taken as num).toInt();
    final percentageDouble = percentage is double ? percentage : (percentage as num).toDouble();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCardWidget(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              value: '${percentageDouble.toStringAsFixed(1)}%',
              label: 'Принято',
            ),
            Container(height: 50, width: 1, color: Colors.grey[300]),
            _buildStatCardWidget(
              icon: Icons.medication,
              iconColor: Colors.blue,
              value: '$takenInt / $totalInt',
              label: 'Всего',
            ),
            Container(height: 50, width: 1, color: Colors.grey[300]),
            _buildStatCardWidget(
              icon: Icons.cancel,
              iconColor: Colors.red,
              value: '${totalInt - takenInt}',
              label: 'Пропущено',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardWidget({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDailyChart() {
    final dailyStats = _statistics!['dailyStats'] as List<DailyStat>;

    final allDaysStats = dailyStats.toList();

    if (allDaysStats.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Нет данных для диаграммы')),
        ),
      );
    }

    final groupSize = _getOptimalGroupSize(allDaysStats.length);
    final groupedData = _groupDailyStats(allDaysStats, groupSize);
    final maxTotal = groupedData.map((g) => g.total).reduce((a, b) => a > b ? a : b);
    final minHeight = maxTotal > 0 ? 0.5 : 1.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Выполнение по дням',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getGroupingLabel(groupSize, allDaysStats.length),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxTotal.toDouble(),
                  minY: 0,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= groupedData.length) return const Text('');
                          final group = groupedData[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              group.shortLabel,
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        reservedSize: 30,
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final data = groupedData[group.x.toInt()];
                        final displayTotal = data.total > 0 ? data.total.toString() : '0';
                        return BarTooltipItem(
                          '${data.tooltipLabel}\n${data.taken} / $displayTotal\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '${(data.percentage).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: _getBarColor(data.percentage),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      tooltipBorder: const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  barGroups: groupedData.asMap().entries.map((e) {
                    final index = e.key;
                    final data = e.value;
                    final barColor = _getBarColor(data.percentage);
                    final toY = data.taken > 0 ? data.taken.toDouble() : minHeight;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: toY,
                          color: barColor,
                          width: _getBarWidth(groupedData.length),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                      showingTooltipIndicators: [],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.green, '≥ 80%'),
                const SizedBox(width: 12),
                _buildLegendItem(Colors.orange, '50-79%'),
                const SizedBox(width: 12),
                _buildLegendItem(Colors.red, '< 50%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getOptimalGroupSize(int daysCount) {
    if (daysCount <= 10) return 1;
    if (daysCount <= 20) return 2;
    if (daysCount <= 30) return 3;
    if (daysCount <= 50) return 5;
    if (daysCount <= 100) return 10;
    return 15;
  }

  String _getGroupingLabel(int groupSize, int daysCount) {
    if (groupSize == 1) return 'по дням';
    final groupsCount = (daysCount / groupSize).ceil();
    return 'по $groupSize дням (${groupsCount} групп)';
  }

  double _getBarWidth(int groupsCount) {
    if (groupsCount <= 7) return 30;
    if (groupsCount <= 10) return 24;
    return 18;
  }

  List<GroupedDailyStat> _groupDailyStats(List<DailyStat> stats, int groupSize) {
    if (groupSize == 1) {
      return stats.map((s) => GroupedDailyStat(
        shortLabel: '${s.date.day}',
        tooltipLabel: DateFormat('dd.MM').format(s.date),
        total: s.total,
        taken: s.taken,
        percentage: s.percentage,
        startDate: s.date,
        endDate: s.date,
      )).toList();
    }

    final grouped = <GroupedDailyStat>[];
    for (int i = 0; i < stats.length; i += groupSize) {
      final end = (i + groupSize - 1) < stats.length ? i + groupSize - 1 : stats.length - 1;
      final groupStats = stats.sublist(i, end + 1);

      final total = groupStats.fold(0, (sum, item) => sum + item.total);
      final taken = groupStats.fold(0, (sum, item) => sum + item.taken);
      final percentage = total > 0 ? (taken / total) * 100 : 0.0;

      final startDate = groupStats.first.date;
      final endDate = groupStats.last.date;

      final shortLabel = '${startDate.day}';
      final tooltipLabel = '${DateFormat('dd.MM').format(startDate)}-${DateFormat('dd.MM').format(endDate)}';

      grouped.add(GroupedDailyStat(
        shortLabel: shortLabel,
        tooltipLabel: tooltipLabel,
        total: total,
        taken: taken,
        percentage: percentage,
        startDate: startDate,
        endDate: endDate,
      ));
    }

    return grouped;
  }

  Color _getBarColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMedicineStats() {
    final medicineStats = _statistics!['medicineStats'] as List<MedicineStat>;

    if (medicineStats.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Нет данных по лекарствам за выбранный период')),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'По лекарствам',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...medicineStats.map((stat) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stat.medicineName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${stat.taken}/${stat.total} (${stat.percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          color: stat.percentage >= 80 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: stat.percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      color: stat.percentage >= 80 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}