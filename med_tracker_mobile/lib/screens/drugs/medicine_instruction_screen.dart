import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicineInstructionScreen extends StatelessWidget {
  final String medicineName;
  final Map<String, dynamic> moreInfo;
  final String? sourceUrl;

  const MedicineInstructionScreen({
    super.key,
    required this.medicineName,
    required this.moreInfo,
    this.sourceUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Фильтруем поля, которые НЕ нужно показывать
    final excludedFields = [
      'parsed_at', 'source_site', 'Комментарий', 'more_info_url',
      'source_url', 'parsedAt', 'sourceSite'
    ];

    final displayFields = moreInfo.entries
        .where((entry) =>
    !excludedFields.contains(entry.key) &&
        entry.value != null &&
        entry.value.toString().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(medicineName),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Информация предоставлена из открытых источников',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
            ),
          ),
        ),
      ),
      body: displayFields.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Нет дополнительной информации'),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayFields.length,
        itemBuilder: (context, index) {
          final entry = displayFields[index];
          return ExpandableSection(
            title: entry.key,
            content: entry.value.toString(),
          );
        },
      ),
      bottomNavigationBar: sourceUrl != null && sourceUrl!.isNotEmpty
          ? Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(
            top: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link, size: 16, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Источник: ${_formatSourceUrl(sourceUrl!)}',
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 16),
              onPressed: () => _launchUrl(sourceUrl!),
            ),
          ],
        ),
      )
          : null,
    );
  }

  String _formatSourceUrl(String url) {
    String formatted = url.replaceAll('https://', '').replaceAll('http://', '');
    formatted = formatted.replaceAll('www.', '');
    return formatted;
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    print('🔍 Распарсенный URI: $uri');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// Выпадающий компонент с анимацией сверху вниз
class ExpandableSection extends StatefulWidget {
  final String title;
  final String content;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Заголовок (кликабельный)
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Анимированная стрелка
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isExpanded ? 0.5 : 0.0,
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Полоска-акцент
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Заголовок
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Анимированное содержимое (выезжает сверху вниз)
          SizeTransition(
            sizeFactor: _heightAnimation,
            axisAlignment: -1.0, // Анимация сверху вниз
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}