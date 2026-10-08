import '../../../scanner/data/services/url_forensic_utils.dart';

enum QrPayloadType {
  url,
  plainText,
  wifi,
  tel,
  mailto,
  sms,
  unsupportedProtocol,
}

/// Structured representation of a QR code payload detected from the physical camera.
/// Strictly distinguishes between the internal original URL and safe defanged representations.
class QrPayloadInfo {
  final String rawPayload;
  final QrPayloadType payloadType;
  final bool isUrl;
  final String? originalUrl;
  final String? defangedUrl;
  final String displayContent;
  final String? detectedScheme;

  const QrPayloadInfo({
    required this.rawPayload,
    required this.payloadType,
    required this.isUrl,
    this.originalUrl,
    this.defangedUrl,
    required this.displayContent,
    this.detectedScheme,
  });

  /// Factory that inspects, validates, and normalizes a raw QR code string.
  factory QrPayloadInfo.parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const QrPayloadInfo(
        rawPayload: '',
        payloadType: QrPayloadType.plainText,
        isUrl: false,
        displayContent: 'Empty QR code',
      );
    }

    final lower = trimmed.toLowerCase();

    // 1. Check for specific non-URL protocols
    if (lower.startsWith('wifi:')) {
      return QrPayloadInfo(
        rawPayload: trimmed,
        payloadType: QrPayloadType.wifi,
        isUrl: false,
        displayContent: trimmed,
        detectedScheme: 'WIFI',
      );
    }

    if (lower.startsWith('tel:')) {
      return QrPayloadInfo(
        rawPayload: trimmed,
        payloadType: QrPayloadType.tel,
        isUrl: false,
        displayContent: trimmed,
        detectedScheme: 'tel',
      );
    }

    if (lower.startsWith('mailto:')) {
      return QrPayloadInfo(
        rawPayload: trimmed,
        payloadType: QrPayloadType.mailto,
        isUrl: false,
        displayContent: trimmed,
        detectedScheme: 'mailto',
      );
    }

    if (lower.startsWith('sms:')) {
      return QrPayloadInfo(
        rawPayload: trimmed,
        payloadType: QrPayloadType.sms,
        isUrl: false,
        displayContent: trimmed,
        detectedScheme: 'sms',
      );
    }

    // Dangerous/arbitrary protocols (e.g. javascript:, intent:, file:)
    for (final dp in UrlForensicUtils.dangerousProtocols) {
      if (lower.startsWith(dp)) {
        return QrPayloadInfo(
          rawPayload: trimmed,
          payloadType: QrPayloadType.unsupportedProtocol,
          isUrl: false,
          displayContent: trimmed,
          detectedScheme: dp.replaceAll(':', ''),
        );
      }
    }

    // 2. Check for standard HTTP/HTTPS or raw Web Domains
    final bool startsWithHttp = lower.startsWith('http://') || lower.startsWith('https://');
    final domainRegex = RegExp(
      r'^[a-zA-Z0-9][-a-zA-Z0-9]*\.[a-zA-Z]{2,}(/[^\s]*)?$',
      caseSensitive: false,
    );

    if (startsWithHttp || domainRegex.hasMatch(trimmed)) {
      try {
        final normalized = UrlForensicUtils.normalize(trimmed);
        return QrPayloadInfo(
          rawPayload: trimmed,
          payloadType: QrPayloadType.url,
          isUrl: true,
          originalUrl: normalized.normalizedUrl,
          defangedUrl: normalized.defangedUrl,
          displayContent: normalized.defangedUrl,
          detectedScheme: normalized.protocol,
        );
      } catch (_) {
        // If normalization fails (e.g. malformed hostname), fall back to plain text
      }
    }

    // 3. Fallback: Generic Plain Text (never auto-executed)
    return QrPayloadInfo(
      rawPayload: trimmed,
      payloadType: QrPayloadType.plainText,
      isUrl: false,
      displayContent: trimmed,
    );
  }
}
