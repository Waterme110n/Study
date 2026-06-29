// lib/models/medicine.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String? id;
  final String name;
  final String? genericName;
  final String? dosageForm;
  final String? dosage;
  final String? manufacturer;
  final String? country;
  final DateTime? createdAt;
  final bool? isPersonal;
  final Map<String, dynamic>? moreInfo;
  final String? sourceUrl;

  Medicine({
    this.id,
    required this.name,
    this.genericName,
    this.dosageForm,
    this.dosage,
    this.manufacturer,
    this.country,
    this.createdAt,
    this.isPersonal = false,
    this.moreInfo,
    this.sourceUrl,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (genericName != null) 'genericName': genericName,
    if (dosageForm != null) 'dosageForm': dosageForm,
    if (dosage != null) 'dosage': dosage,
    if (manufacturer != null) 'manufacturer': manufacturer,
    if (country != null) 'country': country,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    if (moreInfo != null) 'more_info': moreInfo,
    if (sourceUrl != null) 'source_url': sourceUrl,
  };

  factory Medicine.fromJson(Map<String, dynamic> json, {String? id}) {
    // Безопасное преобразование Timestamp
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    // Безопасное преобразование more_info
    Map<String, dynamic>? parseMoreInfo(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      return null;
    }

    return Medicine(
      id: id ?? json['id'] as String?,
      name: json['name'] as String? ?? '',
      genericName: json['genericName'] as String?,
      dosageForm: json['dosageForm'] as String?,
      dosage: json['dosage'] as String?,
      manufacturer: json['manufacturer'] as String?,
      country: json['country'] as String?,
      createdAt: parseTimestamp(json['createdAt']),
      isPersonal: json['isPersonal'] ?? false,
      moreInfo: parseMoreInfo(json['more_info']),
      sourceUrl: json['source_url'] as String?,
    );
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? genericName,
    String? dosageForm,
    String? dosage,
    String? manufacturer,
    String? country,
    DateTime? createdAt,
    bool? isPersonal,
    Map<String, dynamic>? moreInfo,
    String? sourceUrl,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      dosageForm: dosageForm ?? this.dosageForm,
      dosage: dosage ?? this.dosage,
      manufacturer: manufacturer ?? this.manufacturer,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      isPersonal: isPersonal ?? this.isPersonal,
      moreInfo: moreInfo ?? this.moreInfo,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }
}