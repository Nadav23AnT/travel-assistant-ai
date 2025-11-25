import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../providers/currency_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _aiProvider = 'openai';
  String _aiModel = 'gpt-4';
  String _defaultCurrency = AppConstants.defaultCurrency;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _tripReminders = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    // Load currency from the user's profile via provider
    final homeCurrency = ref.read(userHomeCurrencyProvider);
    if (homeCurrency.isNotEmpty) {
      setState(() {
        _defaultCurrency = homeCurrency;
        _isLoading = false;
      });
    } else {
      // Fallback: try to load from the async provider
      try {
        await ref.read(loadUserHomeCurrencyProvider.future);
        final loadedCurrency = ref.read(userHomeCurrencyProvider);
        setState(() {
          _defaultCurrency = loadedCurrency;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateCurrency(String currency) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Update in database
      await Supabase.instance.client.from('profiles').update({
        'default_currency': currency,
      }).eq('id', user.id);

      // Update the provider
      ref.read(userHomeCurrencyProvider.notifier).state = currency;

      setState(() => _defaultCurrency = currency);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Currency updated'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update currency: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // AI Preferences
                _buildSectionHeader(context, 'AI PREFERENCES'),
                _buildSettingTile(
                  context,
                  title: 'AI Provider',
                  subtitle: _getProviderName(_aiProvider),
                  onTap: () => _showProviderPicker(context),
                ),
                _buildSettingTile(
                  context,
                  title: 'AI Model',
                  subtitle: _aiModel,
                  onTap: () => _showModelPicker(context),
                ),

                // Defaults
                _buildSectionHeader(context, 'DEFAULTS'),
                _buildSettingTile(
                  context,
                  title: 'Default Currency',
                  subtitle: _defaultCurrency,
                  onTap: () => _showCurrencyPicker(context),
                ),

                // Notifications
                _buildSectionHeader(context, 'NOTIFICATIONS'),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push notifications'),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() => _pushNotifications = value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive email updates'),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() => _emailNotifications = value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Trip Reminders'),
                  subtitle: const Text('Get reminders before trips'),
                  value: _tripReminders,
                  onChanged: (value) {
                    setState(() => _tripReminders = value);
                  },
                ),

                // Account
                _buildSectionHeader(context, 'ACCOUNT'),
                _buildSettingTile(
                  context,
                  title: 'Change Password',
                  onTap: () {
                    // TODO: Navigate to change password
                  },
                ),
                _buildSettingTile(
                  context,
                  title: 'Export My Data',
                  onTap: () {
                    // TODO: Implement data export
                  },
                ),
                _buildSettingTile(
                  context,
                  title: 'Delete Account',
                  titleColor: AppTheme.errorColor,
                  onTap: () => _showDeleteAccountDialog(context),
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  String _getProviderName(String provider) {
    switch (provider) {
      case 'openai':
        return 'OpenAI';
      case 'openrouter':
        return 'OpenRouter';
      case 'gemini':
        return 'Google Gemini';
      default:
        return provider;
    }
  }

  void _showProviderPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            'Select AI Provider',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('OpenAI'),
            subtitle: const Text('GPT-4, GPT-3.5 Turbo'),
            trailing:
                _aiProvider == 'openai' ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => _aiProvider = 'openai');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.hub),
            title: const Text('OpenRouter'),
            subtitle: const Text('Multiple models (Coming Soon)'),
            enabled: false,
            trailing: _aiProvider == 'openrouter'
                ? const Icon(Icons.check)
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.stars),
            title: const Text('Google Gemini'),
            subtitle: const Text('Gemini Pro (Coming Soon)'),
            enabled: false,
            trailing:
                _aiProvider == 'gemini' ? const Icon(Icons.check) : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showModelPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            'Select AI Model',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('GPT-4'),
            subtitle: const Text('Most capable, best quality'),
            trailing: _aiModel == 'gpt-4' ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => _aiModel = 'gpt-4');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('GPT-4 Turbo'),
            subtitle: const Text('Faster, more efficient'),
            trailing:
                _aiModel == 'gpt-4-turbo' ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => _aiModel = 'gpt-4-turbo');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('GPT-3.5 Turbo'),
            subtitle: const Text('Fast and cost-effective'),
            trailing:
                _aiModel == 'gpt-3.5-turbo' ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => _aiModel = 'gpt-3.5-turbo');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            'Select Default Currency',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...AppConstants.supportedCurrencies.map(
            (currency) => ListTile(
              title: Text(currency),
              trailing:
                  _defaultCurrency == currency ? const Icon(Icons.check) : null,
              onTap: () {
                _updateCurrency(currency);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
