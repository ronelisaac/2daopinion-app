class CountryConfig {
  const CountryConfig({required this.code, required this.currency});

  final String code;
  final String currency;

  static const chile = CountryConfig(code: 'CL', currency: 'CLP');
}
