import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_colors.dart';
import 'xai_result_model.dart';

class XaiPresetBenchmark {
  static final List<XaiResultModel> presets = [
    // 1. Phishing Website
    XaiResultModel(
      id: 'XAI-WEB-01',
      target: 'https://secure-chase-update.com/verify-account',
      category: 'Website',
      threatType: 'Fake Banking Login Portal (Phishing)',
      riskScore: 96,
      confidence: 0.992,
      severity: XaiSeverity.critical,
      plainEnglishSummary:
          'This is a counterfeit website designed by criminals to look identical to Chase Bank. Its sole purpose is to trick you into typing your bank username, password, and security codes so they can access your money.',
      howItWorks:
          'When you enter your login details on this page, your password is not sent to Chase Bank. Instead, it is transmitted directly to a private criminal server overseas within seconds.',
      realWorldAnalogy:
          'Think of this like a scammer setting up a fake ATM machine made of painted cardboard right next to a real bank branch, recording your card and PIN when you try to insert it.',
      evidenceList: const [
        XaiEvidenceItem(
          title: 'Suspicious Domain Name',
          description:
              'Uses "secure-chase-update.com" instead of the official "chase.com". Real banks never use hyphenated subdomains.',
          severityWeight: 0.95,
          icon: Icons.link_off_rounded,
        ),
        XaiEvidenceItem(
          title: 'Brand-New Website Age',
          description:
              'Domain was registered only 48 hours ago using an anonymous privacy proxy in Eastern Europe.',
          severityWeight: 0.92,
          icon: Icons.calendar_month_rounded,
        ),
        XaiEvidenceItem(
          title: 'Insecure SSL Certificate',
          description:
              'Free automated Let\'s Encrypt certificate instead of the Extended Validation (EV) certificate owned by JPMorgan Chase.',
          severityWeight: 0.88,
          icon: Icons.lock_open_rounded,
        ),
        XaiEvidenceItem(
          title: 'Direct Password Form Harvesting',
          description:
              'HTML source code submits credentials to an external IP address (185.220.101.44) known for cybercrime.',
          severityWeight: 0.98,
          icon: Icons.key_off_rounded,
        ),
      ],
      factorMetrics: const [
        XaiFactorMetric(
          name: 'Domain Authenticity',
          score: 0.96,
          summary: 'Critical Typosquatted Domain',
          color: CyberColors.riskCritical,
        ),
        XaiFactorMetric(
          name: 'Credential Safety',
          score: 0.98,
          summary: 'Active Password Harvester',
          color: CyberColors.riskCritical,
        ),
        XaiFactorMetric(
          name: 'Domain Age & History',
          score: 0.92,
          summary: 'Registered <48 Hours Ago',
          color: CyberColors.riskWarning,
        ),
        XaiFactorMetric(
          name: 'SSL/TLS Trust',
          score: 0.85,
          summary: 'Mismatched Enterprise Token',
          color: CyberColors.riskWarning,
        ),
      ],
      recommendedActions: const [
        'Close this webpage immediately and do not enter any information.',
        'Never click login links sent via email or text message. Always type the real address (e.g. chase.com) into your browser.',
        'If you already entered your password, log in to your official bank app immediately from another device and change your password and freeze cards.',
      ],
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),

    // 2. Scam Phone Call
    XaiResultModel(
      id: 'XAI-CALL-02',
      target: '+1 (800) 492-9182',
      category: 'Phone',
      threatType: 'Government Impersonation & Arrest Extortion',
      riskScore: 94,
      confidence: 0.978,
      severity: XaiSeverity.critical,
      plainEnglishSummary:
          'This is a robocall scam where fraudsters pretend to be IRS tax officers. They falsely claim you owe back taxes and threaten arrest or lawsuits unless you pay immediately.',
      howItWorks:
          'Scammers use software to spoof a toll-free number on your caller ID. They use automated fear tactics and demand payment via cryptocurrency, gift cards, or wire transfers which cannot be refunded.',
      realWorldAnalogy:
          'Like an impostor wearing a cheap fake police uniform knocking on your door and demanding cash on the spot to avoid being arrested.',
      evidenceList: const [
        XaiEvidenceItem(
          title: 'Over 2,800 Community Fraud Reports',
          description:
              'Massive volume of crowdsourced complaints within the past 7 days reporting arrest threats.',
          severityWeight: 0.96,
          icon: Icons.people_alt_rounded,
        ),
        XaiEvidenceItem(
          title: 'Outbound Toll-Free Caller-ID Spoofing',
          description:
              'Legitimate 1-800 numbers are inbound customer support endpoints and rarely make outbound calls.',
          severityWeight: 0.90,
          icon: Icons.phone_locked_rounded,
        ),
        XaiEvidenceItem(
          title: 'Untraceable VoIP Gateway Routing',
          description:
              'Originates from disposable Bandwidth.com VoIP trunking rather than federal telecom circuits.',
          severityWeight: 0.89,
          icon: Icons.router_rounded,
        ),
      ],
      factorMetrics: const [
        XaiFactorMetric(
          name: 'Caller-ID Authenticity',
          score: 0.94,
          summary: 'Spoofed Caller ID',
          color: CyberColors.riskCritical,
        ),
        XaiFactorMetric(
          name: 'Community Threat Level',
          score: 0.98,
          summary: '2,800+ Extortion Complaints',
          color: CyberColors.riskCritical,
        ),
        XaiFactorMetric(
          name: 'Carrier Reputation',
          score: 0.88,
          summary: 'Virtual Disposable Trunk',
          color: CyberColors.riskWarning,
        ),
      ],
      recommendedActions: const [
        'Hang up immediately and block the caller on your phone.',
        'Remember: Real government agencies (IRS, police) never demand payment over the phone using gift cards, prepaid cards, or crypto.',
        'Do not press any buttons to "speak to an agent"—this confirms your number is active to telemarketers.',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),

    // 3. Quishing QR Code
    XaiResultModel(
      id: 'XAI-QR-03',
      target: 'https://pay-meter-city.parking.xyz/pay?id=8831',
      category: 'QR',
      threatType: 'Quishing / Fraudulent Meter QR Overlay',
      riskScore: 88,
      confidence: 0.955,
      severity: XaiSeverity.critical,
      plainEnglishSummary:
          'This is a fake QR code physically stuck over a legitimate parking meter. When scanned, it leads to a scam website that steals your credit card numbers instead of paying for your parking.',
      howItWorks:
          'Scammers print adhesive QR stickers and place them over real street signs. When you scan to pay, the page charges your card and records your CVV, but your parking is never registered.',
      realWorldAnalogy:
          'Like someone taping a counterfeit coin slot onto a public vending machine to pocket your money while you get nothing.',
      evidenceList: const [
        XaiEvidenceItem(
          title: 'Unofficial Third-Party Domain',
          description:
              'Directs to "parking.xyz" instead of the official city government portal (.gov or municipal domain).',
          severityWeight: 0.91,
          icon: Icons.domain_disabled_rounded,
        ),
        XaiEvidenceItem(
          title: 'Requests Full Card & Billing Data',
          description:
              'Legitimate meters only require parking stall number; this site requests billing address and mother\'s maiden name.',
          severityWeight: 0.88,
          icon: Icons.credit_card_off_rounded,
        ),
      ],
      factorMetrics: const [
        XaiFactorMetric(
          name: 'QR Payload Safety',
          score: 0.88,
          summary: 'Rogue QR Redirect',
          color: CyberColors.riskCritical,
        ),
        XaiFactorMetric(
          name: 'Payment Gateway Trust',
          score: 0.92,
          summary: 'Unverified Checkout Portal',
          color: CyberColors.riskCritical,
        ),
      ],
      recommendedActions: const [
        'Do not enter your credit card or personal details.',
        'Pay using the official parking meter coin slot or the city\'s verified mobile app.',
        'Peel or inspect the QR code physically—if it is a sticker placed over another code, report it to local parking authorities.',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),

    // 4. CEO Wire Fraud Email
    XaiResultModel(
      id: 'XAI-EMAIL-04',
      target: 'Urgent Wire Transfer Authorization (CEO Executive Request)',
      category: 'Email',
      threatType: 'Business Email Compromise (BEC)',
      riskScore: 91,
      confidence: 0.980,
      severity: XaiSeverity.critical,
      plainEnglishSummary:
          'An impostor pretending to be the CEO or company executive sent an urgent email demanding an immediate money transfer for a fake vendor invoice.',
      howItWorks:
          'Adversaries register look-alike email domains or compromise email accounts. They use artificial urgency ("I am in a meeting, do not call me") to bypass financial approval controls.',
      realWorldAnalogy:
          'Like receiving a forged letter with your boss\'s signature asking you to deliver cash to an unmarked van behind the building.',
      evidenceList: const [
        XaiEvidenceItem(
          title: 'Mismatched Email Address',
          description:
              'Display name says "Chief Executive", but actual email address is "ceo@executive-internal-corp.net" (fake external domain).',
          severityWeight: 0.95,
          icon: Icons.alternate_email_rounded,
        ),
        XaiEvidenceItem(
          title: 'High Urgency & Secrecy Cues',
          description:
              'Text explicitly instructs "confidential transfer", "do not call", and "urgent deadline today".',
          severityWeight: 0.89,
          icon: Icons.timer_outlined,
        ),
      ],
      factorMetrics: const [
        XaiFactorMetric(
          name: 'Sender Legitimacy',
          score: 0.94,
          summary: 'Failing DMARC/SPF Token',
          color: CyberColors.riskCritical,
        ),
        XaiFactorMetric(
          name: 'Linguistic Urgency',
          score: 0.91,
          summary: 'Extortion / Pressure Cues',
          color: CyberColors.riskWarning,
        ),
      ],
      recommendedActions: const [
        'Never execute money transfers based solely on an email request.',
        'Pick up the phone and call the person directly using a known internal phone number to verify.',
        'Forward the email to your internal IT/Security team for blacklisting.',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    ),

    // 5. Lottery Scam Notification
    XaiResultModel(
      id: 'XAI-NOTIF-05',
      target: 'Push Notification: MegaMillions Global Draw Award (\$750,000)',
      category: 'Notification',
      threatType: 'Lottery Prize Scam & Banking Credential Theft',
      riskScore: 93,
      confidence: 0.984,
      severity: XaiSeverity.critical,
      plainEnglishSummary:
          'This is an advance-fee lottery scam delivered through a deceptive push notification. It falsely claims you won \$750,000 and pressures you to click a link to pay "processing fees" or enter bank details and OTP codes to collect the prize.',
      howItWorks:
          'Criminals blast mass notifications hoping victims believe they won an un-entered lottery. The link directs to a counterfeit claim portal designed to steal bank accounts, national IDs, and immediate wire transfers.',
      realWorldAnalogy:
          'Like an unknown person walking up to you on the sidewalk claiming you won a luxury car in a contest you never entered, but demanding \$500 cash on the spot to hand over the keys.',
      evidenceList: const [
        XaiEvidenceItem(
          title: 'Unsolicited Financial Windfall Pattern',
          description:
              'Claims massive monetary prize for a sweepstake or lottery the user never registered for.',
          severityWeight: 0.97,
          icon: Icons.monetization_on_outlined,
        ),
        XaiEvidenceItem(
          title: 'Artificial 24-Hour Expiration Urgency',
          description:
              'Pressures victim with psychological ticking countdown to bypass rational critical thinking.',
          severityWeight: 0.92,
          icon: Icons.alarm_rounded,
        ),
        XaiEvidenceItem(
          title: 'Unverified Telegram/Toll-Free Claims Link',
          description:
              'Redirects through disposable URL shortener to untraceable offshore contact endpoint.',
          severityWeight: 0.94,
          icon: Icons.link_off_rounded,
        ),
      ],
      factorMetrics: const [
        XaiFactorMetric(
          name: 'Advance-Fee Fraud Signature',
          score: 0.98,
          summary: 'Advance Fee Scam Pattern',
          color: CyberColors.riskCritical,
        ),
        XaiFactorMetric(
          name: 'Linguistic Urgency',
          score: 0.93,
          summary: 'Extreme Fear-Of-Missing-Out Cues',
          color: CyberColors.riskCritical,
        ),
        XaiFactorMetric(
          name: 'Sender Trust Score',
          score: 0.91,
          summary: 'Untrusted Push Gateway',
          color: CyberColors.riskWarning,
        ),
      ],
      recommendedActions: const [
        'Dismiss and delete the notification immediately.',
        'Never pay money, purchase gift cards, or share personal banking info to claim a "prize".',
        'Block notifications from this unrecognized sender app or website domain.',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),

    // 6. Deepfake Image Upload
    XaiResultModel(
      id: 'XAI-DEEPFAKE-06',
      target: 'biometric_face_swap_id_scan.jpg',
      category: 'Deepfake',
      threatType: 'Synthetic Identity Deepfake (GAN Face Swap)',
      riskScore: 92,
      confidence: 0.968,
      severity: XaiSeverity.critical,
      plainEnglishSummary:
          'Prototype Analysis: This image exhibits clear hallmarks of artificial intelligence synthesis. A synthetic face swap was generated over a base photo, creating unnatural boundary gradients along the jawline, irregular corneal eye reflections, and erased skin micro-textures.',
      howItWorks:
          'Generative Adversarial Networks (GANs) superimpose facial features onto a target frame. While human eyes may find it convincing at first glance, forensic inspection detects mathematical anomalies in pixel gradients around facial margins and pupil light physics.',
      realWorldAnalogy:
          "Like someone wearing a digital rubber mask where the edge seams around the neck don't quite match the skin, and the reflection in their eyes doesn't match the lighting in the room.",
      evidenceList: const [
        XaiEvidenceItem(
          title: 'Facial Boundary Gradient Discontinuity',
          description:
              'Statistical contrast variance along jawline margins indicates composite overlay blending (3.42 sigma anomaly).',
          severityWeight: 0.95,
          icon: Icons.face_retouching_natural_rounded,
        ),
        XaiEvidenceItem(
          title: 'Ocular Reflection & Pupil Asymmetry',
          description:
              'Corneal specular highlights diverge in angle and illumination physics between left and right eyes.',
          severityWeight: 0.92,
          icon: Icons.visibility_outlined,
        ),
        XaiEvidenceItem(
          title: 'High-Frequency GAN Artifacts',
          description:
              'Fourier transform spectrum reveals generative micro-texture erasure common in autoencoder neural vocoders/decoders.',
          severityWeight: 0.90,
          icon: Icons.blur_linear_rounded,
        ),
      ],
      factorMetrics: const [
        XaiFactorMetric(
          name: 'Boundary Blending Metric',
          score: 0.95,
          summary: '3.42σ Facial Seam Anomaly',
          color: CyberColors.riskCritical,
        ),
        XaiFactorMetric(
          name: 'Corneal Symmetry Index',
          score: 0.91,
          summary: 'Inconsistent Light Physics',
          color: CyberColors.riskCritical,
        ),
        XaiFactorMetric(
          name: 'GAN Texture Coherence',
          score: 0.94,
          summary: 'Synthetic Smoothing Detected',
          color: CyberColors.riskWarning,
        ),
      ],
      recommendedActions: const [
        'Do not accept this image as a verified government ID or authentic biometric verification.',
        'Request a dynamic live liveness challenge (nodding, blinking, turn head) before authorizing sensitive actions.',
        'Escalate case file to forensic identity fraud inspection unit.',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),

    // 7. Safe Verified Site
    XaiResultModel(
      id: 'XAI-SAFE-07',
      target: 'https://support.apple.com',
      category: 'Website',
      threatType: 'Verified Customer Support Portal',
      riskScore: 3,
      confidence: 0.996,
      severity: XaiSeverity.safe,
      plainEnglishSummary:
          'This is the genuine, official customer support website operated directly by Apple Inc. It is completely safe to browse and access support manuals.',
      howItWorks:
          'Traffic is securely encrypted using Apple Inc\'s cryptographic certificates. No deceptive forms, malware, or phishing indicators are present.',
      realWorldAnalogy:
          'Like walking through the front door of an official Apple Store in a reputable shopping center with full security.',
      evidenceList: const [
        XaiEvidenceItem(
          title: 'Cryptographic Certificate Verified',
          description:
              'Official Extended Validation SSL certificate registered to Apple Inc. in Cupertino, CA.',
          severityWeight: 0.05,
          icon: Icons.verified_user_rounded,
          isFlagged: false,
        ),
        XaiEvidenceItem(
          title: 'Zero Malicious Reports',
          description:
              'Clean reputation across Google Safe Browsing, VirusTotal, and global security feeds.',
          severityWeight: 0.02,
          icon: Icons.check_circle_outline_rounded,
          isFlagged: false,
        ),
      ],
      factorMetrics: const [
        XaiFactorMetric(
          name: 'Domain Authenticity',
          score: 0.03,
          summary: 'Official Apple Inc Registry',
          color: Color(0xFF00FF9D),
        ),
        XaiFactorMetric(
          name: 'SSL/TLS Integrity',
          score: 0.02,
          summary: 'Valid Enterprise Certificate',
          color: Color(0xFF00FF9D),
        ),
      ],
      recommendedActions: const [
        'Safe to proceed. You may log in with your Apple ID on this domain.',
        'Always ensure the URL begins with "https://support.apple.com" before entering account information.',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
