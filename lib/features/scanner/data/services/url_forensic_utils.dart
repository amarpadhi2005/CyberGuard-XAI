class UrlValidationException implements Exception {
  final String message;
  const UrlValidationException(this.message);

  @override
  String toString() => message;
}

class NormalizedUrlData {
  final String originalInput;
  final String normalizedUrl;
  final Uri uri;
  final String domain;
  final String protocol;
  final int? port;
  final String path;
  final String query;
  final String defangedUrl;

  const NormalizedUrlData({
    required this.originalInput,
    required this.normalizedUrl,
    required this.uri,
    required this.domain,
    required this.protocol,
    this.port,
    required this.path,
    required this.query,
    required this.defangedUrl,
  });
}

class UrlForensicUtils {
  static const int maxUrlLength = 2048;

  static const List<String> dangerousProtocols = [
    'javascript:',
    'data:',
    'blob:',
    'file:',
    'vbscript:',
    'about:',
  ];

  /// Validates raw user input and throws [UrlValidationException] on invalid syntax.
  static void validateRawInput(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      throw const UrlValidationException('Please enter a URL.');
    }

    if (trimmed.length > maxUrlLength) {
      throw const UrlValidationException('URL exceeds maximum supported length.');
    }

    final lower = trimmed.toLowerCase();
    for (final dp in dangerousProtocols) {
      if (lower.startsWith(dp)) {
        throw UrlValidationException(
            'Unsupported protocol (${dp.replaceAll(':', '')}). Only HTTP and HTTPS addresses are supported.');
      }
    }
  }

  /// Normalizes the input URL into a single source of truth according to RFC 3986.
  static NormalizedUrlData normalize(String rawInput) {
    validateRawInput(rawInput);
    String clean = rawInput.trim();

    // Default to https:// if no protocol is explicitly provided
    final lowerClean = clean.toLowerCase();
    if (!lowerClean.startsWith('http://') && !lowerClean.startsWith('https://')) {
      clean = 'https://$clean';
    }

    final Uri? parsedUri = Uri.tryParse(clean);
    if (parsedUri == null || parsedUri.host.trim().isEmpty) {
      throw const UrlValidationException('Invalid URL format: missing or invalid hostname.');
    }

    final host = parsedUri.host.trim().toLowerCase();

    // Check for IP address or valid domain syntax
    final isIpv4 = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host);
    final hasDot = host.contains('.');
    final isLocalhost = host == 'localhost';

    if (!isIpv4 && !hasDot && !isLocalhost) {
      throw const UrlValidationException(
          'Invalid URL format: domain must include a valid top-level domain (TLD).');
    }

    final scheme = parsedUri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      throw UrlValidationException('Unsupported protocol "$scheme". Only HTTP and HTTPS are permitted.');
    }

    final port = parsedUri.hasPort ? parsedUri.port : null;
    final path = parsedUri.path.isEmpty ? '/' : parsedUri.path;
    final query = parsedUri.hasQuery ? '?${parsedUri.query}' : '';

    // Reconstruct canonical normalized URL without redundant default ports
    String normalized;
    if (port == null || (scheme == 'http' && port == 80) || (scheme == 'https' && port == 443)) {
      normalized = '$scheme://$host$path$query';
    } else {
      normalized = '$scheme://$host:$port$path$query';
    }

    final defanged = defangUrl(normalized);

    return NormalizedUrlData(
      originalInput: rawInput,
      normalizedUrl: normalized,
      uri: parsedUri,
      domain: host,
      protocol: scheme,
      port: port,
      path: path,
      query: query,
      defangedUrl: defanged,
    );
  }

  /// Reliably defangs a URL for safe display and copying.
  /// Example: https://example.com/login -> hxxps://example[.]com/login
  /// Never prepends or generates https://hxxp:// combinations.
  static String defangUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;

    // 1. Defang protocol
    final lower = trimmed.toLowerCase();
    String protocolDefanged = trimmed;
    if (lower.startsWith('https://')) {
      protocolDefanged = 'hxxps://${trimmed.substring(8)}';
    } else if (lower.startsWith('http://')) {
      protocolDefanged = 'hxxp://${trimmed.substring(7)}';
    } else if (lower.startsWith('ftp://')) {
      protocolDefanged = 'fxp://${trimmed.substring(6)}';
    }

    // 2. Locate hostname/authority to defang '.' to '[.]'
    final schemeSep = protocolDefanged.indexOf('://');
    if (schemeSep == -1) {
      // Standalone domain without scheme
      return trimmed.replaceAll('.', '[.]');
    }

    final afterScheme = protocolDefanged.substring(schemeSep + 3);
    final slashIdx = afterScheme.indexOf('/');
    final questIdx = afterScheme.indexOf('?');

    int endOfHost = afterScheme.length;
    if (slashIdx != -1) endOfHost = slashIdx;
    if (questIdx != -1 && questIdx < endOfHost) endOfHost = questIdx;

    final hostPart = afterScheme.substring(0, endOfHost);
    final rest = afterScheme.substring(endOfHost);

    // Defang dots in the host/authority portion only
    final defangedHost = hostPart.replaceAll('.', '[.]');

    return '${protocolDefanged.substring(0, schemeSep + 3)}$defangedHost$rest';
  }
}
