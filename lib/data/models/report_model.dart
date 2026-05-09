// lib/data/models/report_model.dart
// Report Model for PDF Reports

class ReportModel {
  final String id;
  final String bookingId;
  final String testName;
  final String reportUrl;
  final DateTime generatedAt;
  final DateTime? viewedAt;
  final DateTime? downloadedAt;
  final double fileSize; // in KB
  final bool isSigned;
  final String? signedBy; // Doctor/Lab name

  ReportModel({
    required this.id,
    required this.bookingId,
    required this.testName,
    required this.reportUrl,
    required this.generatedAt,
    this.viewedAt,
    this.downloadedAt,
    this.fileSize = 0,
    this.isSigned = true,
    this.signedBy,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      testName: json['test_name']?.toString() ?? '',
      reportUrl: json['report_url']?.toString() ?? '',
      generatedAt: json['generated_at'] != null
          ? DateTime.parse(json['generated_at'])
          : DateTime.now(),
      viewedAt:
          json['viewed_at'] != null ? DateTime.parse(json['viewed_at']) : null,
      downloadedAt: json['downloaded_at'] != null
          ? DateTime.parse(json['downloaded_at'])
          : null,
      fileSize: (json['file_size'] ?? 0).toDouble(),
      isSigned: json['is_signed'] ?? true,
      signedBy: json['signed_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'test_name': testName,
      'report_url': reportUrl,
      'generated_at': generatedAt.toIso8601String(),
      'viewed_at': viewedAt?.toIso8601String(),
      'downloaded_at': downloadedAt?.toIso8601String(),
      'file_size': fileSize,
      'is_signed': isSigned,
      'signed_by': signedBy,
    };
  }
}
