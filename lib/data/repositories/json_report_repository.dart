// lib/data/repositories/json_report_repository.dart
// JSON Implementation of Report Repository
import 'package:lab_system/services/json_service.dart';
import 'base_report_repository.dart';
import '../models/report_model.dart';

class JsonReportRepository implements BaseReportRepository {
  final JsonService _jsonService = JsonService();

  @override
  Future<List<ReportModel>> getUserReports(String userId) async {
    return await _jsonService.getUserReports(userId);
  }

  @override
  Future<ReportModel?> getReportByBookingId(String bookingId) async {
    // In mock, we don't have direct mapping
    // In real app, this would query database
    return null;
  }

  @override
  Future<String?> downloadReport(String reportUrl) async {
    // Mock download delay
    await Future.delayed(const Duration(seconds: 1));

    // Return local file path (mock)
    return '/storage/emulated/0/Download/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  @override
  Future<void> markReportAsViewed(String reportId) async {
    // In mock, do nothing
    // In real app, update database
  }

  @override
  Future<List<int>?> getReportFile(String reportUrl) async {
    // Mock: return sample bytes
    // In real app, download from URL
    await Future.delayed(const Duration(milliseconds: 500));
    return []; // Empty bytes for mock
  }
}
