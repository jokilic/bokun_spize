class AIMealQuotaError implements Exception {
  final DateTime retryAt;

  const AIMealQuotaError({
    required this.retryAt,
  });

  static AIMealQuotaError? tryParse(Object? details) {
    const maxDateTimeMillis = 8640000000000000;

    if (details case {'reason': 'rate-limited', 'retryAtMillis': final num millis} when millis.isFinite && millis > 0 && millis <= maxDateTimeMillis && millis % 1 == 0) {
      return AIMealQuotaError(
        retryAt: DateTime.fromMillisecondsSinceEpoch(
          millis.toInt(),
          isUtc: true,
        ),
      );
    }

    return null;
  }
}
