// lib/data/repositories/supabase_report_repository.dart
// Supabase Implementation of Report Repository

import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_report_repository.dart';
import '../models/report_model.dart';

class SupabaseReportRepository implements BaseReportRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<ReportModel>> getUserReports(String userId) async {
    try {
      // First get all completed bookings with reports
      final bookings = await _supabase
          .from('bookings')
          .select('*, tests(*)')
          .eq('user_id', userId)
          .inFilter('status', ['report_ready', 'completed']);

      final reports = <ReportModel>[];
      for (final booking in bookings) {
        if (booking['report_url'] != null) {
          reports.add(ReportModel(
            id: 'report_${booking['id']}',
            bookingId: booking['id'],
            testName: booking['tests']['name'],
            reportUrl: booking['report_url'],
            generatedAt:
                DateTime.parse(booking['updated_at'] ?? booking['created_at']),
            fileSize: 0,
            isSigned: true,
            signedBy: 'Thal-Care Lab',
          ));
        }
      }

      return reports;
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }

  @override
  Future<ReportModel?> getReportByBookingId(String bookingId) async {
    try {
      final booking = await _supabase
          .from('bookings')
          .select('*, tests(*)')
          .eq('id', bookingId)
          .single();

      if (booking['report_url'] == null) return null;

      return ReportModel(
        id: 'report_${booking['id']}',
        bookingId: booking['id'],
        testName: booking['tests']['name'],
        reportUrl: booking['report_url'],
        generatedAt:
            DateTime.parse(booking['updated_at'] ?? booking['created_at']),
        fileSize: 0,
        isSigned: true,
        signedBy: 'Thal-Care Lab',
      );
    } catch (e) {
      print('Error fetching report: $e');
      return null;
    }
  }

  @override
  Future<String?> downloadReport(String reportUrl) async {
    try {
      // In production, implement actual file download
      // For now, just return the URL
      return reportUrl;
    } catch (e) {
      print('Error downloading report: $e');
      return null;
    }
  }

  @override
  Future<void> markReportAsViewed(String reportId) async {
    // Update report viewed status
    try {
      final bookingId = reportId.replaceFirst('report_', '');
      await _supabase
          .from('bookings')
          .update({'is_report_viewed': true}).eq('id', bookingId);
    } catch (e) {
      print('Error marking report as viewed: $e');
    }
  }

  @override
  Future<List<int>?> getReportFile(String reportUrl) async {
    try {
      // In production, download actual file bytes
      return null;
    } catch (e) {
      print('Error getting report file: $e');
      return null;
    }
  }
}
