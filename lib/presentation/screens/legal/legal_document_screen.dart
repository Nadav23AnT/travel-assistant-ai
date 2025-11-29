import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme.dart';

/// Enum for the different legal document types
enum LegalDocumentType {
  privacyPolicy('privacy_policy.md', 'Privacy Policy'),
  termsOfService('terms_of_service.md', 'Terms of Service'),
  helpSupport('help_support.md', 'Help & Support');

  const LegalDocumentType(this.fileName, this.title);

  final String fileName;
  final String title;
}

/// Screen to display legal documents rendered from Markdown files
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    super.key,
    required this.documentType,
  });

  final LegalDocumentType documentType;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  String _markdownContent = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMarkdownContent();
  }

  Future<void> _loadMarkdownContent() async {
    try {
      final content = await rootBundle.loadString(
        'legal/${widget.documentType.fileName}',
      );
      setState(() {
        _markdownContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load document: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.documentType.title),
      ),
      body: _buildBody(context, theme, isDark),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadMarkdownContent();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Markdown(
      data: _markdownContent,
      selectable: true,
      padding: const EdgeInsets.all(16),
      onTapLink: (text, href, title) {
        if (href != null) {
          _launchUrl(href);
        }
      },
      styleSheet: MarkdownStyleSheet(
        h1: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        h2: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        h3: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        h4: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        p: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          height: 1.6,
        ),
        listBullet: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        blockquote: theme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.textSecondary,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
              width: 4,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        code: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: isDark
              ? Colors.grey.shade800
              : Colors.grey.shade200,
        ),
        codeblockDecoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerColor,
              width: 1,
            ),
          ),
        ),
        a: TextStyle(
          color: AppTheme.primaryColor,
          decoration: TextDecoration.underline,
        ),
        strong: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        em: theme.textTheme.bodyLarge?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurface,
        ),
        tableHead: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        tableBody: theme.textTheme.bodyMedium,
        tableBorder: TableBorder.all(
          color: theme.dividerColor,
          width: 1,
        ),
        tableCellsPadding: const EdgeInsets.all(8),
      ),
    );
  }
}
