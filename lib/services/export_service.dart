import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/event.dart';
import 'calendar_service.dart';

/// Service for exporting schedules to various formats
class ExportService {
  final CalendarService _calendarService = CalendarService();

  /// Export favorite events to PDF
  Future<bool> exportToPDF(
    List<Event> events, {
    String title = 'My Homecoming Schedule',
  }) async {
    try {
      final pdf = pw.Document();

      // Group events by date
      final eventsByDate = <DateTime, List<Event>>{};
      for (final event in events) {
        final date = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );
        eventsByDate.putIfAbsent(date, () => []).add(event);
      }

      // Sort dates
      final sortedDates = eventsByDate.keys.toList()..sort();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return [
              // Title
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Diaspora Handbook - Homecoming Season Guide',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated on ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Events by date
              ...sortedDates.map((date) {
                final dateEvents = eventsByDate[date]!..sort((a, b) => a.startTime.compareTo(b.startTime));
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 12),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(date),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...dateEvents.map((event) {
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 12),
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Expanded(
                                  child: pw.Text(
                                    event.title,
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.grey200,
                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                                  ),
                                  child: pw.Text(
                                    event.category,
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.grey800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: [
                                pw.Icon(const pw.IconData(0xe8df), size: 12),
                                pw.SizedBox(width: 4),
                                pw.Text(
                                  '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                                  style: const pw.TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              children: [
                                pw.Icon(const pw.IconData(0xe55f), size: 12),
                                pw.SizedBox(width: 4),
                                pw.Expanded(
                                  child: pw.Text(
                                    event.location,
                                    style: const pw.TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            if (event.description.isNotEmpty) ...[
                              pw.SizedBox(height: 8),
                              pw.Text(
                                event.description,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey700,
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                );
              }),
            ];
          },
        ),
      );

      // Save and share PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/homecoming_schedule.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: title,
        text: 'My Homecoming Schedule from Diaspora Handbook',
      );

      return true;
    } catch (e) {
      debugPrint('Error exporting to PDF: $e');
      return false;
    }
  }

  /// Export all favorite events to device calendar
  Future<bool> exportAllToCalendar(List<Event> events) async {
    try {
      int successCount = 0;
      for (final event in events) {
        final success = await _calendarService.addEventToCalendar(event);
        if (success) successCount++;
      }
      return successCount == events.length;
    } catch (e) {
      debugPrint('Error exporting to calendar: $e');
      return false;
    }
  }

  /// Generate a shareable text summary of the schedule
  String generateTextSummary(List<Event> events) {
    final buffer = StringBuffer();
    buffer.writeln('📅 MY HOMECOMING SCHEDULE');
    buffer.writeln('From Diaspora Handbook\n');

    // Group events by date
    final eventsByDate = <DateTime, List<Event>>{};
    for (final event in events) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      eventsByDate.putIfAbsent(date, () => []).add(event);
    }

    // Sort dates
    final sortedDates = eventsByDate.keys.toList()..sort();

    for (final date in sortedDates) {
      final dateEvents = eventsByDate[date]!..sort((a, b) => a.startTime.compareTo(b.startTime));
      
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln(DateFormat('EEEE, MMMM d').format(date).toUpperCase());
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━\n');

      for (final event in dateEvents) {
        buffer.writeln('🎉 ${event.title}');
        buffer.writeln('   ⏰ ${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}');
        buffer.writeln('   📍 ${event.location}');
        buffer.writeln('   🏷️ ${event.category}');
        buffer.writeln();
      }
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Total Events: ${events.length}');

    return buffer.toString();
  }

  /// Share text summary
  Future<void> shareTextSummary(List<Event> events) async {
    final summary = generateTextSummary(events);
    await Share.share(
      summary,
      subject: 'My Homecoming Schedule',
    );
  }
}

