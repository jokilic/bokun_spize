enum AIMealQuotaReason { personal, project }

class AIMealQuotaError implements Exception {
  final DateTime retryAt;
  final AIMealQuotaReason reason;

  const AIMealQuotaError({
    required this.retryAt,
    required this.reason,
  });

  static AIMealQuotaError? tryParse(Object? details) {
    const maxDateTimeMillis = 8640000000000000;

    if (details case {'retryAtMillis': final num millis} when millis.isFinite && millis > 0 && millis <= maxDateTimeMillis && millis % 1 == 0) {
      final reason = switch (details) {
        {'reason': 'project-rate-limited'} => AIMealQuotaReason.project,
        {'reason': 'rate-limited'} => AIMealQuotaReason.personal,
        Map() when !details.containsKey('reason') => AIMealQuotaReason.personal,
        _ => null,
      };

      if (reason != null) {
        return AIMealQuotaError(
          retryAt: DateTime.fromMillisecondsSinceEpoch(
            millis.toInt(),
            isUtc: true,
          ),
          reason: reason,
        );
      }
    }

    return null;
  }
}
