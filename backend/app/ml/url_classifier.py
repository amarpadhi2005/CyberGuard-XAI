import re
from urllib.parse import urlparse, urlunparse
from typing import Dict, List, Tuple, Optional

# High-Abuse / Suspicious TLDs
SUSPICIOUS_TLDS = {
    "top", "xyz", "click", "buzz", "cam", "work", "cfd", "gq", "tk", "ml",
    "ga", "cf", "link", "icu", "sbs", "monster", "fit", "rest", "surf", "live"
}

# Major targeted brands
TARGET_BRANDS = [
    "paypal", "google", "apple", "microsoft", "chase", "wellsfargo",
    "amazon", "netflix", "bankofamerica", "binance", "coinbase", "meta",
    "instagram", "facebook", "twitter", "dropbox", "fidelity", "schwab"
]

# Known URL shortener hosts
KNOWN_SHORTENERS = {
    "bit.ly", "tinyurl.com", "t.co", "is.gd", "buff.ly", "ow.ly",
    "rebrand.ly", "cutt.ly", "shorturl.at", "goo.gl", "qr.ae", "rb.gy"
}

# Simulated Threat Intelligence Blacklist
KNOWN_THREAT_DOMAINS = {
    "paypa1-verify.top",
    "chase-online-update.xyz",
    "free-crypto-giveaway-bot.xyz",
    "apple-id-security-unlock.click",
    "crypto-drainer-auth.sbs",
    "refund-support-portal.rest"
}

# Patterns
IP_ADDRESS_PATTERN = re.compile(r"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
SUSPICIOUS_PATH_PATTERN = re.compile(r"(?i)/(login|signin|verify|account-update|security|auth|wallet|confirm|bank|restore|wp-admin|update|claim|bonus|passcode)(/|\.php|\.html|\.asp|$)")
DANGEROUS_EXT_PATTERN = re.compile(r"(?i)\.(exe|apk|scr|bat|cmd|vbs|msi|jar|ps1)$")

def normalize_url(raw_url: str) -> str:
    """Normalizes URL by stripping whitespace, standardizing scheme, lowercasing, and removing fragments."""
    trimmed = raw_url.strip()
    if not trimmed:
        return ""
    
    # Strip fragment
    if "#" in trimmed:
        trimmed = trimmed.split("#")[0]
        
    # Default scheme
    if not re.match(r"^https?://", trimmed, re.IGNORECASE):
        trimmed = f"https://{trimmed}"

    parsed = urlparse(trimmed)
    scheme = parsed.scheme.lower()
    netloc = parsed.netloc.lower()
    
    # Remove default ports
    if scheme == "http" and netloc.endswith(":80"):
        netloc = netloc[:-3]
    elif scheme == "https" and netloc.endswith(":443"):
        netloc = netloc[:-4]

    path = parsed.path
    if path == "/":
        path = ""
        
    return urlunparse((scheme, netloc, path, parsed.params, parsed.query, ""))

def levenshtein_distance(s1: str, s2: str) -> int:
    """Computes Levenshtein edit distance between two strings."""
    if len(s1) < len(s2):
        return levenshtein_distance(s2, s1)
    if len(s2) == 0:
        return len(s1)

    previous_row = list(range(len(s2) + 1))
    for i, c1 in enumerate(s1):
        current_row = [i + 1]
        for j, c2 in enumerate(s2):
            insertions = previous_row[j + 1] + 1
            deletions = current_row[j] + 1
            substitutions = previous_row[j] + (c1 != c2)
            current_row.append(min(insertions, deletions, substitutions))
        previous_row = current_row
    return previous_row[-1]

def detect_lookalike_domain(host: str) -> Tuple[bool, Optional[str]]:
    """Detects lookalike domains via typosquatting, character substitution, and Levenshtein distance."""
    # Strip port if present
    host_clean = host.split(":")[0]

    for target in TARGET_BRANDS:
        if host_clean == f"{target}.com" or host_clean == f"www.{target}.com":
            continue

        # Subdomain spoof (e.g., paypal.com.evil-portal.xyz)
        if f"{target}." in host_clean and not host_clean.endswith(f".{target}.com"):
            return True, target

        # Character substitutions (paypa1, g00gle)
        substituted = host_clean.replace("0", "o").replace("1", "l").replace("vv", "w").replace("rn", "m")
        if target in substituted and target not in host_clean:
            return True, target

        # Levenshtein distance on primary label
        labels = host_clean.split(".")
        if len(labels) >= 2:
            primary_label = labels[-2]
            dist = levenshtein_distance(primary_label, target)
            if 1 <= dist <= 2 and len(primary_label) >= len(target) - 1:
                return True, target

    return False, None

def evaluate_url_threat(raw_url: str) -> Dict:
    """
    Evaluates URL across 11 features:
    - URL normalization
    - HTTPS check
    - suspicious domain detection
    - lookalike domain detection
    - excessive subdomain detection
    - suspicious path detection
    - IP-address URL detection
    - URL shortening detection
    - known threat lookup
    - risk scoring (0-100)
    - explanation generation
    """
    normalized = normalize_url(raw_url)
    parsed = urlparse(normalized)

    scheme = parsed.scheme.lower()
    host = parsed.netloc.lower().split(":")[0]
    path = parsed.path
    
    is_https = (scheme == "https")
    is_ip_address = bool(IP_ADDRESS_PATTERN.match(host))
    is_shortened = (host in KNOWN_SHORTENERS)
    is_known_threat = (host in KNOWN_THREAT_DOMAINS)

    tld = host.split(".")[-1] if "." in host else ""
    has_suspicious_tld = (tld in SUSPICIOUS_TLDS)

    labels = host.split(".")
    subdomain_count = max(0, len(labels) - 2) if not is_ip_address else 0
    has_excessive_subdomains = (subdomain_count >= 2)

    has_suspicious_path = bool(SUSPICIOUS_PATH_PATTERN.search(path) or DANGEROUS_EXT_PATTERN.search(path))
    has_lookalike, lookalike_target = detect_lookalike_domain(host)

    # Accumulate risk score
    score = 0
    reasons = []

    if is_known_threat:
        score += 100
        reasons.append("Listed in active Threat Intelligence blacklist as a confirmed phishing/malware host")

    if is_ip_address:
        score += 40
        reasons.append(f"URL host is a raw IP address ({host}) bypassing DNS domain governance")

    if has_lookalike and lookalike_target:
        score += 45
        reasons.append(f"Lookalike domain impersonating '{lookalike_target}' via typosquatting / character substitution")

    if has_suspicious_tld:
        score += 30
        reasons.append(f"High-abuse top-level domain (.{tld}) frequently leveraged in malicious campaigns")

    if not is_https:
        if has_suspicious_path:
            score += 30
            reasons.append("Unencrypted HTTP protocol used on sensitive credential/authentication endpoint")
        else:
            score += 15
            reasons.append("Unencrypted HTTP protocol in use; susceptible to interception")

    if has_excessive_subdomains:
        score += 25
        reasons.append(f"Excessive subdomain depth ({subdomain_count} subdomains) commonly used to spoof mobile URL bars")

    if has_suspicious_path:
        score += 20
        reasons.append("Sensitive authentication path keywords or executable extensions detected in URL route")

    if is_shortened:
        score += 20
        reasons.append(f"URL is obfuscated via link shortener ({host}); destination is initially concealed")

    hyphen_count = host.count("-")
    if hyphen_count >= 3:
        score += 15
        reasons.append(f"High frequency of hyphens in domain ({hyphen_count} hyphens) indicating artificial spoofing")

    final_score = min(100, max(0, score))

    if final_score >= 85:
        severity = "CRITICAL"
        recommendation = "CRITICAL THREAT: Do not open link. Disclose no passwords or private data. Domain added to your blocklist."
    elif final_score >= 70:
        severity = "HIGH"
        recommendation = "HIGH RISK: Strong phishing or spoofing indicators present. Avoid navigation unless origin is independently verified."
    elif final_score >= 50:
        severity = "MEDIUM"
        recommendation = "SUSPICIOUS: Exercise caution. Avoid entering login credentials or financial authorization."
    elif final_score >= 25:
        severity = "LOW"
        recommendation = "LOW RISK: Minor heuristic anomalies detected (e.g., URL shortener or unencrypted connection). Proceed with care."
    else:
        severity = "SAFE"
        recommendation = "SAFE: No malicious indicators, lookalike patterns, or threat signatures identified."
        reasons = ["Clean domain reputation and standard HTTPS security configuration"]

    return {
        "riskScore": final_score,
        "severity": severity,
        "reasons": reasons,
        "recommendation": recommendation,
        "normalized_url": normalized,
        "domain": host,
        "is_https": is_https,
        "is_ip_address": is_ip_address,
        "is_shortened": is_shortened,
        "has_lookalike": has_lookalike,
        "lookalike_target": lookalike_target,
        "subdomain_count": subdomain_count,
        "is_known_threat": is_known_threat
    }
