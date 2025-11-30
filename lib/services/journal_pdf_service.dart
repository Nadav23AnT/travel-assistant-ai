import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models/journal_model.dart';
import '../data/models/trip_model.dart';

/// Service for generating beautiful PDF journals
class JournalPdfService {
  // Brand colors
  static const _primaryColor = PdfColor.fromInt(0xFF2196F3); // Blue
  static const _accentColor = PdfColor.fromInt(0xFFFF9800); // Orange
  static const _textPrimary = PdfColor.fromInt(0xFF212121);
  static const _textSecondary = PdfColor.fromInt(0xFF757575);
  static const _backgroundLight = PdfColor.fromInt(0xFFF5F5F5);

  /// Generate a beautiful PDF document from trip journal entries
  Future<Uint8List> generatePdf({
    required TripModel trip,
    required List<JournalModel> entries,
    String? locale,
  }) async {
    final pdf = pw.Document(
      title: '${trip.displayTitle} - Travel Journal',
      author: 'TripBuddy',
      creator: 'TripBuddy Travel Companion',
    );

    // Load cover image if available
    pw.MemoryImage? coverImage;
    if (trip.coverImageUrl != null && trip.coverImageUrl!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(trip.coverImageUrl!));
        if (response.statusCode == 200) {
          coverImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (_) {
        // Fallback to no image
      }
    }

    // Sort entries by date
    final sortedEntries = List<JournalModel>.from(entries)
      ..sort((a, b) => a.entryDate.compareTo(b.entryDate));

    // Add cover page
    pdf.addPage(_buildCoverPage(trip, coverImage, sortedEntries.length));

    // Add journal entry pages
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final dayNumber = trip.startDate != null
          ? entry.getDayNumber(trip.startDate!)
          : i + 1;

      pdf.addPage(_buildEntryPage(entry, dayNumber, trip));
    }

    // Add summary page
    if (sortedEntries.isNotEmpty) {
      pdf.addPage(_buildSummaryPage(trip, sortedEntries));
    }

    return pdf.save();
  }

  /// Build the cover page with trip image and info
  pw.Page _buildCoverPage(TripModel trip, pw.MemoryImage? coverImage, int entryCount) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Stack(
          children: [
            // Background
            if (coverImage != null)
              pw.Positioned.fill(
                child: pw.Opacity(
                  opacity: 0.3,
                  child: pw.Image(coverImage, fit: pw.BoxFit.cover),
                ),
              ),

            // Gradient overlay
            pw.Positioned.fill(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    begin: pw.Alignment.topCenter,
                    end: pw.Alignment.bottomCenter,
                    colors: [
                      PdfColors.white,
                      _primaryColor.shade(0.9),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            pw.Positioned.fill(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(50),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Spacer(flex: 2),

                    // Flag emoji placeholder (as text)
                    pw.Text(
                      trip.flagEmoji,
                      style: pw.TextStyle(fontSize: 60),
                    ),
                    pw.SizedBox(height: 30),

                    // Title
                    pw.Text(
                      trip.displayTitle,
                      style: pw.TextStyle(
                        fontSize: 36,
                        fontWeight: pw.FontWeight.bold,
                        color: _textPrimary,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 15),

                    // Destination
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: _primaryColor,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        trip.displayDestination,
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 40),

                    // Dates
                    if (trip.startDate != null && trip.endDate != null) ...[
                      pw.Text(
                        '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: _textSecondary,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '${trip.durationDays} days',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],

                    pw.Spacer(flex: 3),

                    // Stats bar
                    pw.Container(
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(12),
                        boxShadow: [
                          pw.BoxShadow(
                            color: PdfColors.grey300,
                            blurRadius: 10,
                            offset: const PdfPoint(0, 4),
                          ),
                        ],
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          _buildStatItem('Journal Entries', entryCount.toString()),
                          pw.SizedBox(width: 40),
                          _buildStatItem('Days', trip.durationDays?.toString() ?? '-'),
                        ],
                      ),
                    ),

                    pw.Spacer(),

                    // Footer
                    pw.Text(
                      'Travel Journal',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Created with TripBuddy',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build a single journal entry page
  pw.Page _buildEntryPage(JournalModel entry, int dayNumber, TripModel trip) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with day number and date
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Day badge
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: _primaryColor,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        'DAY',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.Text(
                        dayNumber.toString(),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),

                // Date and mood
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        dateFormat.format(entry.entryDate),
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      if (entry.title != null && entry.title!.isNotEmpty)
                        pw.Text(
                          entry.title!,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                    ],
                  ),
                ),

                // Mood badge
                if (entry.mood != null)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: _accentColor.shade(0.1),
                      borderRadius: pw.BorderRadius.circular(20),
                      border: pw.Border.all(color: _accentColor, width: 1),
                    ),
                    child: pw.Text(
                      '${entry.mood!.emoji} ${entry.mood!.displayName}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: _accentColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey300, thickness: 1),
            pw.SizedBox(height: 20),

            // Content
            pw.Expanded(
              child: pw.Text(
                entry.content,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: _textPrimary,
                  lineSpacing: 6,
                ),
                textAlign: pw.TextAlign.justify,
              ),
            ),

            // Highlights section
            if (entry.highlights.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildSectionWithIcon('Highlights', entry.highlights),
            ],

            // Locations section
            if (entry.locations.isNotEmpty) ...[
              pw.SizedBox(height: 15),
              _buildLocationsSection(entry.locations),
            ],

            // Weather
            if (entry.weather != null && entry.weather!.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Text(
                    'Weather: ',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _textSecondary,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    entry.weather!,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ],

            // Footer
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  trip.displayTitle,
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _textSecondary,
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Build the summary page with trip stats
  pw.Page _buildSummaryPage(TripModel trip, List<JournalModel> entries) {
    // Calculate stats
    final moodCounts = <JournalMood, int>{};
    final allLocations = <String>{};
    final allHighlights = <String>[];

    for (final entry in entries) {
      if (entry.mood != null) {
        moodCounts[entry.mood!] = (moodCounts[entry.mood!] ?? 0) + 1;
      }
      allLocations.addAll(entry.locations);
      allHighlights.addAll(entry.highlights);
    }

    // Get top mood
    JournalMood? topMood;
    int topMoodCount = 0;
    for (final entry in moodCounts.entries) {
      if (entry.value > topMoodCount) {
        topMoodCount = entry.value;
        topMood = entry.key;
      }
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Center(
              child: pw.Text(
                'Trip Summary',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                trip.displayTitle,
                style: pw.TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                ),
              ),
            ),
            pw.SizedBox(height: 30),

            // Stats grid
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: _backgroundLight,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryStatBox('Journal Entries', entries.length.toString()),
                  _buildSummaryStatBox('Days', trip.durationDays?.toString() ?? '-'),
                  _buildSummaryStatBox('Places Visited', allLocations.length.toString()),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Top mood
            if (topMood != null) ...[
              pw.Text(
                'Most Common Mood',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: _accentColor.shade(0.1),
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: _accentColor),
                ),
                child: pw.Row(
                  children: [
                    pw.Text(
                      topMood.emoji,
                      style: const pw.TextStyle(fontSize: 30),
                    ),
                    pw.SizedBox(width: 15),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          topMood.displayName,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: _accentColor,
                          ),
                        ),
                        pw.Text(
                          '$topMoodCount out of ${entries.length} entries',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
            ],

            // Places visited
            if (allLocations.isNotEmpty) ...[
              pw.Text(
                'Places Visited',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allLocations.take(15).map((location) =>
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: _primaryColor.shade(0.1),
                      borderRadius: pw.BorderRadius.circular(15),
                    ),
                    child: pw.Text(
                      location,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ).toList(),
              ),
              pw.SizedBox(height: 30),
            ],

            // Top highlights
            if (allHighlights.isNotEmpty) ...[
              pw.Text(
                'Trip Highlights',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              pw.SizedBox(height: 10),
              ...allHighlights.take(8).map((highlight) =>
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 6,
                        height: 6,
                        margin: const pw.EdgeInsets.only(top: 4, right: 10),
                        decoration: pw.BoxDecoration(
                          color: _accentColor,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          highlight,
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            pw.Spacer(),

            // Footer
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'Thank you for traveling with TripBuddy!',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Generated on ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper widgets

  pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryStatBox(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 32,
            fontWeight: pw.FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 11,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSectionWithIcon(String title, List<String> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _backgroundLight,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.map((item) =>
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Text(
                  item,
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _textPrimary,
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLocationsSection(List<String> locations) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            color: _primaryColor.shade(0.1),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            'PLACES',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
              letterSpacing: 1,
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(
            locations.join(' • '),
            style: pw.TextStyle(
              fontSize: 10,
              color: _textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
