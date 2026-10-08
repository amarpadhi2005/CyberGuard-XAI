package com.cyberguard.xai.core.rules

import com.cyberguard.xai.domain.model.UrlThreatEvaluation
import com.cyberguard.xai.presentation.components.RiskSeverity
import java.net.URI
import java.util.regex.Pattern
import kotlin.math.min

object UrlThreatDetector {

    // 1. High-Abuse / Suspicious TLDs
    private val SUSPICIOUS_TLDS = setOf(
        "top", "xyz", "click", "buzz", "cam", "work", "cfd", "gq", "tk", "ml",
        "ga", "cf", "link", "icu", "sbs", "monster", "fit", "rest", "surf", "live"
    )

    // 2. High-Value Target Brands for Lookalike / Typosquatting Analysis
    private val TARGET_BRANDS = listOf(
        "paypal", "google", "apple", "microsoft", "chase", "wellsfargo",
        "amazon", "netflix", "bankofamerica", "binance", "coinbase", "meta",
        "instagram", "facebook", "twitter", "dropbox", "fidelity", "schwab"
    )

    // 3. Known URL Shorteners
    private val KNOWN_SHORTENERS = setOf(
        "bit.ly", "tinyurl.com", "t.co", "is.gd", "buff.ly", "ow.ly",
        "rebrand.ly", "cutt.ly", "shorturl.at", "goo.gl", "qr.ae", "rb.gy"
    )

    // 4. Known Threat Blacklist Signatures (Simulated Threat Intel Registry)
    private val KNOWN_THREAT_DOMAINS = setOf(
        "paypa1-verify.top",
        "chase-online-update.xyz",
        "free-crypto-giveaway-bot.xyz",
        "apple-id-security-unlock.click",
        "crypto-drainer-auth.sbs",
        "refund-support-portal.rest"
    )

    // 5. Suspicious Paths & File Extensions
    private val SUSPICIOUS_PATH_PATTERN = Pattern.compile(
        """(?i)/(?:login|signin|verify|account-update|security|auth|wallet|confirm|bank|restore|wp-admin|update|claim|bonus|passcode)(?:/|\.php|\.html|\.asp|${'$'})"""
    )
    private val DANGEROUS_EXTENSIONS = Pattern.compile(
        """(?i)\.(?:exe|apk|scr|bat|cmd|vbs|msi|jar|ps1)${'$'}"""
    )

    // 6. IP Address Pattern (IPv4)
    private val IP_ADDRESS_REGEX = Pattern.compile(
        """^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)${'$'}"""
    )

    fun evaluate(rawUrl: String): UrlThreatEvaluation {
        val normalized = normalizeUrl(rawUrl)
        val uri = try {
            URI(normalized)
        } catch (_: Exception) {
            // Irregular string fallback
            return createMalformedUrlEvaluation(rawUrl, normalized)
        }

        val scheme = uri.scheme?.lowercase() ?: "http"
        val host = uri.host?.lowercase() ?: ""
        val path = uri.path ?: ""
        val query = uri.query ?: ""

        val isHttps = scheme == "https"
        val isIpAddress = IP_ADDRESS_REGEX.matcher(host).matches()
        val isShortened = KNOWN_SHORTENERS.contains(host)
        val isKnownThreat = KNOWN_THREAT_DOMAINS.contains(host)

        val tld = extractTld(host)
        val hasSuspiciousTld = SUSPICIOUS_TLDS.contains(tld)

        // Subdomain analysis
        val hostParts = host.split(".")
        val subdomainCount = if (hostParts.size > 2) hostParts.size - 2 else 0
        val hasExcessiveSubdomains = subdomainCount >= 2

        // Path & Extension Analysis
        val fullPath = if (query.isNotBlank()) "$path?$query" else path
        val hasSuspiciousPath = SUSPICIOUS_PATH_PATTERN.matcher(path).find() ||
                DANGEROUS_EXTENSIONS.matcher(path).find()

        // Lookalike & Typosquatting Analysis
        val lookalikeResult = detectLookalikeDomain(host)
        val hasLookalikeDomain = lookalikeResult.first
        val lookalikeTarget = lookalikeResult.second

        // Calculate Risk Score and collect reasons
        var score = 0
        val reasons = mutableListOf<String>()

        if (isKnownThreat) {
            score += 100
            reasons.add("Listed in active Threat Intelligence blacklist as a confirmed phishing/malware host")
        }

        if (isIpAddress) {
            score += 40
            reasons.add("URL host is a raw IP address ($host) bypassing DNS domain governance")
        }

        if (hasLookalikeDomain && lookalikeTarget != null) {
            score += 45
            reasons.add("Lookalike domain impersonating '$lookalikeTarget' via typosquatting / character substitution")
        }

        if (hasSuspiciousTld) {
            score += 30
            reasons.add("High-abuse top-level domain (.$tld) frequently leveraged in malicious campaigns")
        }

        if (!isHttps) {
            if (hasSuspiciousPath) {
                score += 30
                reasons.add("Unencrypted HTTP protocol used on sensitive credential/authentication endpoint")
            } else {
                score += 15
                reasons.add("Unencrypted HTTP protocol in use; susceptible to Man-In-The-Middle inspection")
            }
        }

        if (hasExcessiveSubdomains) {
            score += 25
            reasons.add("Excessive subdomain depth ($subdomainCount subdomains) commonly used to spoof mobile URL bars")
        }

        if (hasSuspiciousPath) {
            score += 20
            reasons.add("Sensitive authentication path keywords or executable extensions detected in URL route")
        }

        if (isShortened) {
            score += 20
            reasons.add("URL is obfuscated via link shortener ($host); destination is initially concealed")
        }

        // Hyphen abuse check (e.g. chase-online-banking-security-update.com)
        val hyphenCount = host.count { it == '-' }
        if (hyphenCount >= 3) {
            score += 15
            reasons.add("High frequency of hyphens in domain ($hyphenCount hyphens) indicating artificial spoofing")
        }

        val finalScore = score.coerceIn(0, 100)

        val severity = when {
            finalScore >= 85 -> RiskSeverity.CRITICAL
            finalScore >= 70 -> RiskSeverity.HIGH
            finalScore >= 50 -> RiskSeverity.MEDIUM
            finalScore >= 25 -> RiskSeverity.LOW
            else -> RiskSeverity.SAFE
        }

        val recommendation = when {
            finalScore >= 85 -> "CRITICAL THREAT: Do not open link. Disclose no passwords or private data. Domain added to your blocklist."
            finalScore >= 70 -> "HIGH RISK: Strong phishing or spoofing indicators present. Avoid navigation unless origin is independently verified."
            finalScore >= 50 -> "SUSPICIOUS: Exercise caution. Avoid entering login credentials or financial authorization."
            finalScore >= 25 -> "LOW RISK: Minor heuristic anomalies detected (e.g., URL shortener or unencrypted connection). Proceed with care."
            else -> "SAFE: No malicious indicators, lookalike patterns, or threat signatures identified."
        }

        return UrlThreatEvaluation(
            normalizedUrl = normalized,
            domain = host,
            isHttps = isHttps,
            isIpAddress = isIpAddress,
            isShortened = isShortened,
            hasLookalikeDomain = hasLookalikeDomain,
            lookalikeTarget = lookalikeTarget,
            hasExcessiveSubdomains = hasExcessiveSubdomains,
            subdomainCount = subdomainCount,
            hasSuspiciousPath = hasSuspiciousPath,
            hasSuspiciousTld = hasSuspiciousTld,
            isKnownThreat = isKnownThreat,
            riskScore = finalScore,
            severity = severity,
            reasons = if (reasons.isNotEmpty()) reasons else listOf("Clean domain reputation and standard HTTPS security configuration"),
            recommendation = recommendation
        )
    }

    /**
     * Normalizes a URL:
     * - Trims whitespace
     * - Adds default https:// if scheme is missing
     * - Lowercases scheme and host
     * - Removes standard default ports (:80, :443)
     * - Strips fragments (#...)
     * - Removes redundant trailing slash for host roots
     */
    fun normalizeUrl(rawUrl: String): String {
        var trimmed = rawUrl.trim()
        if (trimmed.isBlank()) return ""

        // Strip fragment
        val fragmentIndex = trimmed.indexOf('#')
        if (fragmentIndex != -1) {
            trimmed = trimmed.substring(0, fragmentIndex)
        }

        // Add scheme if missing
        if (!trimmed.startsWith("http://", ignoreCase = true) &&
            !trimmed.startsWith("https://", ignoreCase = true)
        ) {
            trimmed = "https://$trimmed"
        }

        return try {
            val uri = URI(trimmed)
            val scheme = uri.scheme?.lowercase() ?: "https"
            var host = uri.host?.lowercase() ?: ""
            val port = uri.port
            var path = uri.path ?: ""
            val query = uri.query

            // Default port normalization
            val portPart = if (port != -1 && port != 80 && port != 443) ":$port" else ""

            if (path == "/") {
                path = ""
            }

            val queryPart = if (!query.isNullOrBlank()) "?$query" else ""
            "$scheme://$host$portPart$path$queryPart"
        } catch (_: Exception) {
            trimmed
        }
    }

    private fun extractTld(host: String): String {
        val parts = host.split(".")
        return if (parts.size >= 2) parts.last() else ""
    }

    /**
     * Detects lookalike / typosquatting domains targeting major platforms.
     */
    private fun detectLookalikeDomain(host: String): Pair<Boolean, String?> {
        val cleanHost = host.replace("-", "").replace(".", "")

        for (target in TARGET_BRANDS) {
            // 1. Exact match is the real brand (unless high-abuse TLD or subdomain spoof)
            if (host == "$target.com" || host == "www.$target.com") {
                continue
            }

            // 2. Target brand used as an unauthorized subdomain (e.g. paypal.com.auth-service.xyz)
            if (host.contains("$target.") && !host.endsWith(".$target.com") && host != "$target.com") {
                return Pair(true, target)
            }

            // 3. Typosquatting / Character Substitution (e.g. paypa1, g00gle)
            val substituted = host
                .replace("0", "o")
                .replace("1", "l")
                .replace("vv", "w")
                .replace("rn", "m")

            if (substituted.contains(target) && !host.contains(target)) {
                return Pair(true, target)
            }

            // 4. Levenshtein Distance Check on primary domain label
            val domainName = host.split(".").let {
                if (it.size >= 2) it[it.size - 2] else host
            }

            val dist = computeLevenshteinDistance(domainName, target)
            if (dist in 1..2 && domainName.length >= target.length - 1) {
                return Pair(true, target)
            }
        }

        return Pair(false, null)
    }

    private fun computeLevenshteinDistance(s1: String, s2: String): Int {
        val dp = Array(s1.length + 1) { IntArray(s2.length + 1) }

        for (i in 0..s1.length) dp[i][0] = i
        for (j in 0..s2.length) dp[0][j] = j

        for (i in 1..s1.length) {
            for (j in 1..s2.length) {
                val cost = if (s1[i - 1] == s2[j - 1]) 0 else 1
                dp[i][j] = min(
                    dp[i - 1][j] + 1,
                    min(dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost)
                )
            }
        }
        return dp[s1.length][s2.length]
    }

    private fun createMalformedUrlEvaluation(raw: String, normalized: String) = UrlThreatEvaluation(
        normalizedUrl = normalized,
        domain = raw,
        isHttps = false,
        isIpAddress = false,
        isShortened = false,
        hasLookalikeDomain = false,
        lookalikeTarget = null,
        hasExcessiveSubdomains = false,
        subdomainCount = 0,
        hasSuspiciousPath = false,
        hasSuspiciousTld = false,
        isKnownThreat = false,
        riskScore = 55,
        severity = RiskSeverity.MEDIUM,
        reasons = listOf("Malformed or non-standard URI syntax prevents standard DNS resolution"),
        recommendation = "Do not navigate to irregular or non-standard formatted URLs."
    )
}
