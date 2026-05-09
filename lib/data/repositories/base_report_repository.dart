// lib/data/repositories/base_report_repository.dart
// Abstract Repository for Reports

import '../models/report_model.dart';

abstract class BaseReportRepository {
  // Get all reports for a user
  Future<List<ReportModel>> getUserReports(String userId);

  // Get report by booking ID
  Future<ReportModel?> getReportByBookingId(String bookingId);

  // Download report PDF
  Future<String?> downloadReport(String reportUrl);

  // Mark report as viewed
  Future<void> markReportAsViewed(String reportId);

  // Get report file as bytes
  Future<List<int>?> getReportFile(String reportUrl);
}
