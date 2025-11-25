import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CurrencyServiceException implements Exception {
  final String message;

  CurrencyServiceException(this.message);

  @override
  String toString() => message;
}

class CurrencyService {
  static const String _baseUrl = 'https://api.frankfurter.app';

  final http.Client _client;

  CurrencyService({http.Client? client}) : _client = client ?? http.Client();

  /// Get exchange rates from a base currency
  /// Returns a map of currency codes to their rates relative to the base
  Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/latest?from=$baseCurrency'),
      );

      if (response.statusCode != 200) {
        throw CurrencyServiceException(
          'Failed to fetch exchange rates: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>;

      // Convert to double map and add base currency with rate 1.0
      final result = <String, double>{baseCurrency: 1.0};
      for (final entry in rates.entries) {
        result[entry.key] = (entry.value as num).toDouble();
      }

      return result;
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
      if (e is CurrencyServiceException) rethrow;
      throw CurrencyServiceException('Failed to fetch exchange rates: $e');
    }
  }

  /// Convert an amount from one currency to another
  Future<double> convert(double amount, String from, String to) async {
    if (from == to) return amount;

    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/latest?amount=$amount&from=$from&to=$to'),
      );

      if (response.statusCode != 200) {
        throw CurrencyServiceException(
          'Failed to convert currency: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>;

      if (!rates.containsKey(to)) {
        throw CurrencyServiceException('Currency $to not found in rates');
      }

      return (rates[to] as num).toDouble();
    } catch (e) {
      debugPrint('Error converting currency: $e');
      if (e is CurrencyServiceException) rethrow;
      throw CurrencyServiceException('Failed to convert currency: $e');
    }
  }

  /// Convert amount synchronously using cached rates
  double convertSync(
    double amount,
    String from,
    String to,
    Map<String, double> rates,
  ) {
    if (from == to) return amount;

    // If rates are based on 'from' currency, direct conversion
    if (rates.containsKey(to)) {
      return amount * rates[to]!;
    }

    // If rates are based on a different currency, we need to convert through it
    if (rates.containsKey(from) && rates[from] != null) {
      // Convert through base currency
      final amountInBase = amount / rates[from]!;
      return amountInBase * (rates[to] ?? 1.0);
    }

    // Fallback: return original amount if conversion not possible
    debugPrint('Warning: Could not convert $from to $to with provided rates');
    return amount;
  }

  /// Get a single exchange rate between two currencies
  Future<double> getExchangeRate(String from, String to) async {
    if (from == to) return 1.0;

    try {
      final rates = await getExchangeRates(from);
      return rates[to] ?? 1.0;
    } catch (e) {
      debugPrint('Error getting exchange rate: $e');
      rethrow;
    }
  }

  /// Get available currencies from frankfurter API
  Future<List<String>> getAvailableCurrencies() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/currencies'),
      );

      if (response.statusCode != 200) {
        throw CurrencyServiceException(
          'Failed to fetch currencies: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data.keys.toList()..sort();
    } catch (e) {
      debugPrint('Error fetching currencies: $e');
      if (e is CurrencyServiceException) rethrow;
      throw CurrencyServiceException('Failed to fetch currencies: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
