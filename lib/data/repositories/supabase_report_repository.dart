// lib/data/repositories/supabase_report_repository.dart
// Supabase Implementation of Report Repository (UPDATED - uses reports table)

import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_report_repository.dart';
import '../models/report_model.dart';

class SupabaseReportRepository implements BaseReportRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<ReportModel>> getUserReports(String userId) async {
    try {
      // Fetch from dedicated reports table
      final response = await _supabase
          .from('reports')
          .select('*, bookings!inner(test_id, tests!inner(name))')
          .eq('uploaded_by', userId)
          .order('uploaded_at', ascending: false);

      final reports = <ReportModel>[];
      for (final report in response) {
        final booking = report['bookings'] as Map<String, dynamic>?;
        final test = booking?['tests'] as Map<String, dynamic>?;

        reports.add(ReportModel(
          id: report['id'],
          bookingId: report['booking_id'],
          testName: test?['name'] ?? 'Diagnostic Report',
          reportUrl: report['file_url'],
          generatedAt: DateTime.parse(report['uploaded_at']),
          fileSize: (report['file_size'] as num?)?.toDouble() ?? 0,
          isSigned: true,
          signedBy: 'Thal-Care Lab',
        ));
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
      final response = await _supabase
          .from('reports')
          .select('*, bookings!inner(test_id, tests!inner(name))')
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (response == null) return null;

      final booking = response['bookings'] as Map<String, dynamic>?;
      final test = booking?['tests'] as Map<String, dynamic>?;

      return ReportModel(
        id: response['id'],
        bookingId: response['booking_id'],
        testName: test?['name'] ?? 'Diagnostic Report',
        reportUrl: response['file_url'],
        generatedAt: DateTime.parse(response['uploaded_at']),
        fileSize: (response['file_size'] as num?)?.toDouble() ?? 0,
        isSigned: true,
        signedBy: 'Thal-Care Lab',
      );
    } catch (e) {
      print('Error fetching report by booking: $e');
      return null;
    }
  }

  @override
  Future<String?> downloadReport(String reportUrl) async {
    try {
      // Download file from Supabase Storage
      final response =
          await _supabase.storage.from('reports').download(reportUrl);
      // Save to device
      // TODO: Implement file save to device
      return reportUrl;
    } catch (e) {
      print('Error downloading report: $e');
      return null;
    }
  }

  @override
  Future<void> markReportAsViewed(String reportId) async {
    try {
      await _supabase
          .from('reports')
          .update({'is_viewed': true}).eq('id', reportId);
    } catch (e) {
      print('Error marking report as viewed: $e');
    }
  }

  @override
  Future<List<int>?> getReportFile(String reportUrl) async {
    try {
      final response =
          await _supabase.storage.from('reports').download(reportUrl);
      return response;
    } catch (e) {
      print('Error getting report file: $e');
      return null;
    }
  }
}
