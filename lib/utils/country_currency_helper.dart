/// Helper utilities for country and currency mapping.
/// This is the single source of truth for all country-currency relationships.
class CountryCurrencyHelper {
  // Private constructor to prevent instantiation
  CountryCurrencyHelper._();

  /// Map of country names to their default currency codes
  static const Map<String, String> countryToCurrency = {
    // Asia
    'Thailand': 'THB',
    'Vietnam': 'VND',
    'Japan': 'JPY',
    'South Korea': 'KRW',
    'China': 'CNY',
    'Taiwan': 'TWD',
    'Hong Kong': 'HKD',
    'Singapore': 'SGD',
    'Malaysia': 'MYR',
    'Indonesia': 'IDR',
    'Philippines': 'PHP',
    'India': 'INR',
    'Sri Lanka': 'LKR',
    'Nepal': 'NPR',
    'Cambodia': 'KHR',
    'Laos': 'LAK',
    'Myanmar': 'MMK',
    'Bangladesh': 'BDT',
    'Pakistan': 'PKR',
    'United Arab Emirates': 'AED',
    'Saudi Arabia': 'SAR',
    'Israel': 'ILS',
    'Turkey': 'TRY',
    'Qatar': 'QAR',
    'Kuwait': 'KWD',
    'Bahrain': 'BHD',
    'Oman': 'OMR',
    'Jordan': 'JOD',
    'Lebanon': 'LBP',

    // Europe
    'United Kingdom': 'GBP',
    'Switzerland': 'CHF',
    'Norway': 'NOK',
    'Sweden': 'SEK',
    'Denmark': 'DKK',
    'Poland': 'PLN',
    'Czech Republic': 'CZK',
    'Hungary': 'HUF',
    'Romania': 'RON',
    'Bulgaria': 'BGN',
    'Croatia': 'EUR',
    'Russia': 'RUB',
    'Ukraine': 'UAH',
    'Iceland': 'ISK',
    // Eurozone countries
    'Germany': 'EUR',
    'France': 'EUR',
    'Italy': 'EUR',
    'Spain': 'EUR',
    'Portugal': 'EUR',
    'Netherlands': 'EUR',
    'Belgium': 'EUR',
    'Austria': 'EUR',
    'Ireland': 'EUR',
    'Finland': 'EUR',
    'Greece': 'EUR',
    'Luxembourg': 'EUR',
    'Slovenia': 'EUR',
    'Slovakia': 'EUR',
    'Estonia': 'EUR',
    'Latvia': 'EUR',
    'Lithuania': 'EUR',
    'Malta': 'EUR',
    'Cyprus': 'EUR',

    // Americas
    'United States': 'USD',
    'Canada': 'CAD',
    'Mexico': 'MXN',
    'Brazil': 'BRL',
    'Argentina': 'ARS',
    'Chile': 'CLP',
    'Colombia': 'COP',
    'Peru': 'PEN',
    'Ecuador': 'USD',
    'Costa Rica': 'CRC',
    'Panama': 'USD',
    'Dominican Republic': 'DOP',
    'Jamaica': 'JMD',
    'Cuba': 'CUP',
    'Puerto Rico': 'USD',
    'Uruguay': 'UYU',
    'Paraguay': 'PYG',
    'Bolivia': 'BOB',
    'Venezuela': 'VES',
    'Guatemala': 'GTQ',
    'Honduras': 'HNL',
    'El Salvador': 'USD',
    'Nicaragua': 'NIO',
    'Bahamas': 'BSD',
    'Barbados': 'BBD',
    'Trinidad and Tobago': 'TTD',

    // Oceania
    'Australia': 'AUD',
    'New Zealand': 'NZD',
    'Fiji': 'FJD',
    'Papua New Guinea': 'PGK',

    // Africa
    'South Africa': 'ZAR',
    'Egypt': 'EGP',
    'Morocco': 'MAD',
    'Kenya': 'KES',
    'Tanzania': 'TZS',
    'Nigeria': 'NGN',
    'Ghana': 'GHS',
    'Ethiopia': 'ETB',
    'Tunisia': 'TND',
    'Algeria': 'DZD',
    'Rwanda': 'RWF',
    'Uganda': 'UGX',
    'Botswana': 'BWP',
    'Namibia': 'NAD',
    'Zimbabwe': 'ZWL',
    'Mauritius': 'MUR',
    'Seychelles': 'SCR',
    'Madagascar': 'MGA',
  };

  /// Map of currency codes to their symbols
  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '\u20AC',
    'GBP': '\u00A3',
    'JPY': '\u00A5',
    'CNY': '\u00A5',
    'ILS': '\u20AA',
    'THB': '\u0E3F',
    'VND': '\u20AB',
    'KRW': '\u20A9',
    'INR': '\u20B9',
    'RUB': '\u20BD',
    'BRL': 'R\$',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'CHF': 'CHF',
    'HKD': 'HK\$',
    'SGD': 'S\$',
    'NZD': 'NZ\$',
    'MXN': 'MX\$',
    'ZAR': 'R',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
    'PLN': 'z\u0142',
    'CZK': 'K\u010D',
    'HUF': 'Ft',
    'TRY': '\u20BA',
    'MYR': 'RM',
    'IDR': 'Rp',
    'PHP': '\u20B1',
    'TWD': 'NT\$',
    'AED': 'AED',
    'SAR': 'SAR',
    'EGP': 'E\u00A3',
    'QAR': 'QAR',
    'KWD': 'KWD',
    'ARS': 'AR\$',
    'CLP': 'CL\$',
    'COP': 'CO\$',
    'PEN': 'S/',
  };

  /// Map of major cities to their countries
  static const Map<String, String> cityToCountry = {
    // Asia
    'Bangkok': 'Thailand',
    'Phuket': 'Thailand',
    'Chiang Mai': 'Thailand',
    'Pattaya': 'Thailand',
    'Krabi': 'Thailand',
    'Koh Samui': 'Thailand',
    'Ho Chi Minh City': 'Vietnam',
    'Hanoi': 'Vietnam',
    'Da Nang': 'Vietnam',
    'Hoi An': 'Vietnam',
    'Tokyo': 'Japan',
    'Osaka': 'Japan',
    'Kyoto': 'Japan',
    'Sapporo': 'Japan',
    'Fukuoka': 'Japan',
    'Seoul': 'South Korea',
    'Busan': 'South Korea',
    'Beijing': 'China',
    'Shanghai': 'China',
    'Guangzhou': 'China',
    'Shenzhen': 'China',
    'Hong Kong': 'Hong Kong',
    'Taipei': 'Taiwan',
    'Singapore': 'Singapore',
    'Kuala Lumpur': 'Malaysia',
    'Penang': 'Malaysia',
    'Jakarta': 'Indonesia',
    'Bali': 'Indonesia',
    'Manila': 'Philippines',
    'Cebu': 'Philippines',
    'Mumbai': 'India',
    'Delhi': 'India',
    'New Delhi': 'India',
    'Bangalore': 'India',
    'Chennai': 'India',
    'Kolkata': 'India',
    'Jaipur': 'India',
    'Goa': 'India',
    'Kathmandu': 'Nepal',
    'Colombo': 'Sri Lanka',
    'Siem Reap': 'Cambodia',
    'Phnom Penh': 'Cambodia',
    'Vientiane': 'Laos',
    'Luang Prabang': 'Laos',
    'Yangon': 'Myanmar',
    'Dubai': 'United Arab Emirates',
    'Abu Dhabi': 'United Arab Emirates',
    'Tel Aviv': 'Israel',
    'Jerusalem': 'Israel',
    'Istanbul': 'Turkey',
    'Antalya': 'Turkey',
    'Doha': 'Qatar',
    'Riyadh': 'Saudi Arabia',
    'Amman': 'Jordan',
    'Beirut': 'Lebanon',

    // Europe
    'London': 'United Kingdom',
    'Manchester': 'United Kingdom',
    'Edinburgh': 'United Kingdom',
    'Liverpool': 'United Kingdom',
    'Paris': 'France',
    'Nice': 'France',
    'Lyon': 'France',
    'Marseille': 'France',
    'Berlin': 'Germany',
    'Munich': 'Germany',
    'Frankfurt': 'Germany',
    'Hamburg': 'Germany',
    'Rome': 'Italy',
    'Milan': 'Italy',
    'Venice': 'Italy',
    'Florence': 'Italy',
    'Naples': 'Italy',
    'Madrid': 'Spain',
    'Barcelona': 'Spain',
    'Seville': 'Spain',
    'Valencia': 'Spain',
    'Lisbon': 'Portugal',
    'Porto': 'Portugal',
    'Amsterdam': 'Netherlands',
    'Brussels': 'Belgium',
    'Vienna': 'Austria',
    'Zurich': 'Switzerland',
    'Geneva': 'Switzerland',
    'Dublin': 'Ireland',
    'Prague': 'Czech Republic',
    'Budapest': 'Hungary',
    'Warsaw': 'Poland',
    'Krakow': 'Poland',
    'Copenhagen': 'Denmark',
    'Stockholm': 'Sweden',
    'Oslo': 'Norway',
    'Helsinki': 'Finland',
    'Athens': 'Greece',
    'Santorini': 'Greece',
    'Mykonos': 'Greece',
    'Moscow': 'Russia',
    'St Petersburg': 'Russia',
    'Reykjavik': 'Iceland',
    'Zagreb': 'Croatia',
    'Dubrovnik': 'Croatia',
    'Split': 'Croatia',
    'Bucharest': 'Romania',
    'Sofia': 'Bulgaria',
    'Ljubljana': 'Slovenia',
    'Bratislava': 'Slovakia',
    'Tallinn': 'Estonia',
    'Riga': 'Latvia',
    'Vilnius': 'Lithuania',
    'Valletta': 'Malta',

    // Americas
    'New York': 'United States',
    'Los Angeles': 'United States',
    'San Francisco': 'United States',
    'Chicago': 'United States',
    'Miami': 'United States',
    'Las Vegas': 'United States',
    'Seattle': 'United States',
    'Boston': 'United States',
    'Washington DC': 'United States',
    'Orlando': 'United States',
    'Hawaii': 'United States',
    'Honolulu': 'United States',
    'Toronto': 'Canada',
    'Vancouver': 'Canada',
    'Montreal': 'Canada',
    'Mexico City': 'Mexico',
    'Cancun': 'Mexico',
    'Playa del Carmen': 'Mexico',
    'Rio de Janeiro': 'Brazil',
    'Sao Paulo': 'Brazil',
    'Buenos Aires': 'Argentina',
    'Lima': 'Peru',
    'Cusco': 'Peru',
    'Bogota': 'Colombia',
    'Cartagena': 'Colombia',
    'Medellin': 'Colombia',
    'Santiago': 'Chile',
    'San Jose': 'Costa Rica',
    'Panama City': 'Panama',
    'Havana': 'Cuba',
    'San Juan': 'Puerto Rico',
    'Punta Cana': 'Dominican Republic',
    'Montego Bay': 'Jamaica',
    'Nassau': 'Bahamas',

    // Oceania
    'Sydney': 'Australia',
    'Melbourne': 'Australia',
    'Brisbane': 'Australia',
    'Perth': 'Australia',
    'Gold Coast': 'Australia',
    'Auckland': 'New Zealand',
    'Wellington': 'New Zealand',
    'Queenstown': 'New Zealand',
    'Fiji': 'Fiji',

    // Africa
    'Cape Town': 'South Africa',
    'Johannesburg': 'South Africa',
    'Cairo': 'Egypt',
    'Luxor': 'Egypt',
    'Marrakech': 'Morocco',
    'Casablanca': 'Morocco',
    'Nairobi': 'Kenya',
    'Mombasa': 'Kenya',
    'Zanzibar': 'Tanzania',
    'Dar es Salaam': 'Tanzania',
    'Lagos': 'Nigeria',
    'Accra': 'Ghana',
    'Addis Ababa': 'Ethiopia',
    'Tunis': 'Tunisia',
    'Kigali': 'Rwanda',
    'Victoria': 'Seychelles',
    'Port Louis': 'Mauritius',
  };

  /// Get currency code for a country
  static String getCurrencyForCountry(String country) {
    return countryToCurrency[country] ?? 'USD';
  }

  /// Get currency symbol for a currency code
  static String getSymbolForCurrency(String currencyCode) {
    return currencySymbols[currencyCode] ?? currencyCode;
  }

  /// Get currency symbol for a country
  static String getSymbolForCountry(String country) {
    final currency = getCurrencyForCountry(country);
    return getSymbolForCurrency(currency);
  }

  /// Get country from a city or location name
  /// Returns the input if it's already a country or unknown
  static String getCountryFromLocation(String location) {
    // Check if it's already a country
    if (countryToCurrency.containsKey(location)) {
      return location;
    }

    // Check if it's a known city
    if (cityToCountry.containsKey(location)) {
      return cityToCountry[location]!;
    }

    // Try partial matching for cities
    for (final entry in cityToCountry.entries) {
      if (location.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(location.toLowerCase())) {
        return entry.value;
      }
    }

    // Try partial matching for countries
    for (final country in countryToCurrency.keys) {
      if (location.toLowerCase().contains(country.toLowerCase()) ||
          country.toLowerCase().contains(location.toLowerCase())) {
        return country;
      }
    }

    // Return as-is if unknown
    return location;
  }

  /// Extract country from a destination string that might be "City, Country"
  static String extractCountryFromDestination(String destination) {
    // Check if destination contains a comma (e.g., "Bangkok, Thailand")
    if (destination.contains(',')) {
      final parts = destination.split(',');
      if (parts.length >= 2) {
        final lastPart = parts.last.trim();
        // Check if the last part is a known country
        if (countryToCurrency.containsKey(lastPart)) {
          return lastPart;
        }
      }
    }

    // Otherwise, try to map the destination to a country
    return getCountryFromLocation(destination);
  }

  /// Get default currency for a destination (city or country)
  static String getCurrencyForDestination(String destination) {
    final country = extractCountryFromDestination(destination);
    return getCurrencyForCountry(country);
  }

  /// Format amount with currency symbol
  static String formatAmount(double amount, String currencyCode) {
    final symbol = getSymbolForCurrency(currencyCode);

    // Handle currencies that typically don't show decimals
    final noDecimalCurrencies = {'JPY', 'KRW', 'VND', 'IDR', 'CLP', 'HUF'};

    if (noDecimalCurrencies.contains(currencyCode)) {
      return '$symbol${amount.toStringAsFixed(0)}';
    }

    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Get a list of common currencies for dropdown selection
  static List<String> get commonCurrencies => [
    'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'AUD', 'CAD', 'CHF',
    'THB', 'VND', 'ILS', 'INR', 'SGD', 'HKD', 'MYR', 'KRW',
    'MXN', 'BRL', 'ZAR', 'AED', 'TRY', 'PLN', 'CZK', 'SEK',
    'NOK', 'DKK', 'NZD', 'PHP', 'IDR', 'TWD',
  ];

  /// Check if a string is a known country
  static bool isCountry(String text) {
    return countryToCurrency.containsKey(text);
  }

  /// Check if a string is a known city
  static bool isCity(String text) {
    return cityToCountry.containsKey(text);
  }

  /// Map of country names to their ISO 3166-1 alpha-2 codes
  static const Map<String, String> countryToCode = {
    // Asia
    'Thailand': 'TH',
    'Vietnam': 'VN',
    'Japan': 'JP',
    'South Korea': 'KR',
    'China': 'CN',
    'Taiwan': 'TW',
    'Hong Kong': 'HK',
    'Singapore': 'SG',
    'Malaysia': 'MY',
    'Indonesia': 'ID',
    'Philippines': 'PH',
    'India': 'IN',
    'Sri Lanka': 'LK',
    'Nepal': 'NP',
    'Cambodia': 'KH',
    'Laos': 'LA',
    'Myanmar': 'MM',
    'Bangladesh': 'BD',
    'Pakistan': 'PK',
    'United Arab Emirates': 'AE',
    'Saudi Arabia': 'SA',
    'Israel': 'IL',
    'Turkey': 'TR',
    'Qatar': 'QA',
    'Kuwait': 'KW',
    'Bahrain': 'BH',
    'Oman': 'OM',
    'Jordan': 'JO',
    'Lebanon': 'LB',
    // Europe
    'United Kingdom': 'GB',
    'Switzerland': 'CH',
    'Norway': 'NO',
    'Sweden': 'SE',
    'Denmark': 'DK',
    'Poland': 'PL',
    'Czech Republic': 'CZ',
    'Hungary': 'HU',
    'Romania': 'RO',
    'Bulgaria': 'BG',
    'Croatia': 'HR',
    'Russia': 'RU',
    'Ukraine': 'UA',
    'Iceland': 'IS',
    'Germany': 'DE',
    'France': 'FR',
    'Italy': 'IT',
    'Spain': 'ES',
    'Portugal': 'PT',
    'Netherlands': 'NL',
    'Belgium': 'BE',
    'Austria': 'AT',
    'Ireland': 'IE',
    'Finland': 'FI',
    'Greece': 'GR',
    'Luxembourg': 'LU',
    'Slovenia': 'SI',
    'Slovakia': 'SK',
    'Estonia': 'EE',
    'Latvia': 'LV',
    'Lithuania': 'LT',
    'Malta': 'MT',
    'Cyprus': 'CY',
    // Americas
    'United States': 'US',
    'Canada': 'CA',
    'Mexico': 'MX',
    'Brazil': 'BR',
    'Argentina': 'AR',
    'Chile': 'CL',
    'Colombia': 'CO',
    'Peru': 'PE',
    'Ecuador': 'EC',
    'Costa Rica': 'CR',
    'Panama': 'PA',
    'Dominican Republic': 'DO',
    'Jamaica': 'JM',
    'Cuba': 'CU',
    'Puerto Rico': 'PR',
    'Uruguay': 'UY',
    'Paraguay': 'PY',
    'Bolivia': 'BO',
    'Venezuela': 'VE',
    'Guatemala': 'GT',
    'Honduras': 'HN',
    'El Salvador': 'SV',
    'Nicaragua': 'NI',
    'Bahamas': 'BS',
    'Barbados': 'BB',
    'Trinidad and Tobago': 'TT',
    // Oceania
    'Australia': 'AU',
    'New Zealand': 'NZ',
    'Fiji': 'FJ',
    'Papua New Guinea': 'PG',
    // Africa
    'South Africa': 'ZA',
    'Egypt': 'EG',
    'Morocco': 'MA',
    'Kenya': 'KE',
    'Tanzania': 'TZ',
    'Nigeria': 'NG',
    'Ghana': 'GH',
    'Ethiopia': 'ET',
    'Tunisia': 'TN',
    'Algeria': 'DZ',
    'Rwanda': 'RW',
    'Uganda': 'UG',
    'Botswana': 'BW',
    'Namibia': 'NA',
    'Zimbabwe': 'ZW',
    'Mauritius': 'MU',
    'Seychelles': 'SC',
    'Madagascar': 'MG',
  };

  /// Get emoji flag for a country code (ISO 3166-1 alpha-2)
  /// Uses regional indicator symbols to form flag emoji
  static String getFlagEmoji(String countryCode) {
    // Convert country code to regional indicator symbols
    // A = 🇦 (U+1F1E6), B = 🇧 (U+1F1E7), etc.
    final code = countryCode.toUpperCase();
    if (code.length != 2) return '🏳️';

    final firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;

    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  /// Get flag emoji for a country name
  static String getFlagForCountry(String country) {
    final code = countryToCode[country];
    if (code == null) return '🏳️';
    return getFlagEmoji(code);
  }

  /// Get flag emoji for a destination (city or country)
  static String getFlagForDestination(String destination) {
    final country = extractCountryFromDestination(destination);
    return getFlagForCountry(country);
  }
}
