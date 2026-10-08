import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../threat_history/domain/entities/threat_history_item.dart';
import '../../../xai_result/domain/entities/xai_preset_benchmark.dart';
import '../../../xai_result/domain/entities/xai_result_model.dart';

class DemoSimulationScenario {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final ThreatCategory category;
  final IconData icon;
  final Color accentColor;
  final String simulatedTarget;
  final String threatType;
  final int riskScore;
  final String reason;
  final String recommendedAction;
  final int healthScorePenalty;
  final List<String> simulationSteps;
  final XaiResultModel xaiModel;

  const DemoSimulationScenario({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.icon,
    required this.accentColor,
    required this.simulatedTarget,
    required this.threatType,
    required this.riskScore,
    required this.reason,
    required this.recommendedAction,
    this.healthScorePenalty = -60,
    required this.simulationSteps,
    required this.xaiModel,
  });

  /// Factory list containing all 6 required hackathon demo scenarios
  static List<DemoSimulationScenario> getAllScenarios() {
    final presets = XaiPresetBenchmark.presets;

    // Map presets by ID or fallback
    final webPreset = presets.firstWhere((p) => p.id == 'XAI-WEB-01');
    final callPreset = presets.firstWhere((p) => p.id == 'XAI-CALL-02');
    final qrPreset = presets.firstWhere((p) => p.id == 'XAI-QR-03');
    final emailPreset = presets.firstWhere((p) => p.id == 'XAI-EMAIL-04');
    final notifPreset = presets.firstWhere((p) => p.id == 'XAI-NOTIF-05');
    final deepfakePreset = presets.firstWhere((p) => p.id == 'XAI-DEEPFAKE-06');

    return [
      // 1. Incoming Scam Call
      DemoSimulationScenario(
        id: 'sim_scam_call',
        title: 'Incoming Scam Call',
        subtitle: 'Robocall Extortion & Caller-ID Spoofing',
        description:
            'Simulates an incoming robocall spoofing an official 1-800 toll-free number threatening legal arrest unless immediate payment is wired.',
        category: ThreatCategory.phone,
        icon: Icons.phone_in_talk_rounded,
        accentColor: CyberColors.emergencyRed,
        simulatedTarget: '+1 (800) 492-9182',
        threatType: 'Government Impersonation & Arrest Extortion',
        riskScore: 94,
        reason:
            'STIR/SHAKEN cryptographic handshake failed. Untraceable VoIP carrier routing detected with 2,800+ community extortion reports.',
        recommendedAction:
            'Hang up immediately. Government agencies never demand gift card, wire, or cryptocurrency transfers.',
        healthScorePenalty: -60,
        simulationSteps: const [
          'Simulating incoming cellular signal from +1 (800) 492-9182...',
          'Inspecting telecom STIR/SHAKEN cryptographic attestation tokens...',
          'Gemini Audio NLP transcribing speech: "Immediate arrest warrant issued"...',
          'Flagging extortion robocall & matching 2,800+ community fraud reports...',
        ],
        xaiModel: callPreset,
      ),

      // 2. Phishing Email
      DemoSimulationScenario(
        id: 'sim_phishing_email',
        title: 'Phishing Email',
        subtitle: 'CEO Business Email Compromise (BEC)',
        description:
            'Simulates an executive impersonation email demanding an urgent confidential wire transfer to bypass corporate procurement controls.',
        category: ThreatCategory.email,
        icon: Icons.mark_email_unread_rounded,
        accentColor: CyberColors.cyberPurple,
        simulatedTarget: 'ceo@executive-internal-corp.net',
        threatType: 'Business Email Compromise (BEC)',
        riskScore: 91,
        reason:
            'Mismatched domain envelope with failed DMARC/SPF cryptographic tokens. High-pressure linguistic urgency cues detected.',
        recommendedAction:
            'Do not execute wire transfer. Contact the executive directly via verified internal telephone number.',
        healthScorePenalty: -60,
        simulationSteps: const [
          'Intercepting incoming multipart email MIME stream...',
          'Validating DMARC, DKIM, and SPF cryptographic sender integrity...',
          'Gemini NLP extracting coercive urgency cues: "Confidential wire transfer"...',
          'Flagging Business Email Compromise (BEC) and look-alike domain spoofing...',
        ],
        xaiModel: emailPreset,
      ),

      // 3. Malicious QR Code
      DemoSimulationScenario(
        id: 'sim_malicious_qr',
        title: 'Malicious QR Code',
        subtitle: 'Quishing / Parking Meter Adhesive Sticker',
        description:
            'Simulates scanning a rogue adhesive QR code placed over a public parking meter redirecting to an unauthorized payment form.',
        category: ThreatCategory.qr,
        icon: Icons.qr_code_2_rounded,
        accentColor: CyberColors.neonPink,
        simulatedTarget: 'https://pay-meter-city.parking.xyz/pay?id=8831',
        threatType: 'Quishing / Fraudulent Meter QR Overlay',
        riskScore: 88,
        reason:
            'Directs to unverified third-party domain "parking.xyz" rather than official municipal government portal. Captures full CVV and personal credentials.',
        recommendedAction:
            'Do not enter credit card info. Pay using official street meter coin slot or official city parking app.',
        healthScorePenalty: -60,
        simulationSteps: const [
          'Simulating camera optical 2D barcode matrix capture...',
          'Extracting decoded payload URL: pay-meter-city.parking.xyz...',
          'Probing destination DNS (Not an official .gov or municipal portal)...',
          'Detecting rogue credit card harvester & untrusted checkout gateway...',
        ],
        xaiModel: qrPreset,
      ),

      // 4. Fake Banking Website
      DemoSimulationScenario(
        id: 'sim_fake_banking_website',
        title: 'Fake Banking Website',
        subtitle: 'Typosquatted Chase Bank Credential Scraper',
        description:
            'Simulates visiting a counterfeit online banking login page designed to siphon account credentials and MFA session tokens.',
        category: ThreatCategory.website,
        icon: Icons.language_rounded,
        accentColor: CyberColors.neonCyan,
        simulatedTarget: 'https://secure-chase-update.com/verify-account',
        threatType: 'Fake Banking Login Portal (Phishing)',
        riskScore: 96,
        reason:
            'Typosquatted domain registered <48 hours ago using anonymous offshore proxy. HTML forms transmit credentials to known criminal IP.',
        recommendedAction:
            'Close website immediately. Type official banking URL directly into browser and change credentials if compromised.',
        healthScorePenalty: -100,
        simulationSteps: const [
          'Simulating browser zero-trust pre-flight connection...',
          'Inspecting SSL/TLS certificate: Automated Let\'s Encrypt (Not JPMorgan Chase)...',
          'Evaluating domain WHOIS telemetry: Registered <48 hours ago...',
          'Detecting active HTML password harvesting script submitting to external IP...',
        ],
        xaiModel: webPreset,
      ),

      // 5. Lottery Scam Notification
      DemoSimulationScenario(
        id: 'sim_lottery_notification',
        title: 'Lottery Scam Notification',
        subtitle: 'Advance-Fee Prize Notification & KYC Theft',
        description:
            'Simulates receiving a deceptive push notification claiming an un-entered \$750,000 sweepstakes win requiring immediate fee payment.',
        category: ThreatCategory.notification,
        icon: Icons.notifications_active_rounded,
        accentColor: CyberColors.riskWarning,
        simulatedTarget: 'Push: MegaMillions Global Draw (\$750,000)',
        threatType: 'Lottery Prize Scam & Banking Credential Theft',
        riskScore: 93,
        reason:
            'Classic advance-fee fraud indicators with artificial 24-hour expiration urgency and untrusted international messaging claim endpoint.',
        recommendedAction:
            'Dismiss and block notifications from this source. Never pay money or share bank details to claim prizes.',
        healthScorePenalty: -60,
        simulationSteps: const [
          'Simulating incoming system push notification intent...',
          'Parsing notification payload: "You have won \$750,000! Claim in 24h"...',
          'Correlating against advance-fee fraud signatures & fraudulent KYC links...',
          'Flagging deceptive banking credential theft & urgent payment scheme...',
        ],
        xaiModel: notifPreset,
      ),

      // 6. Deepfake Image Upload
      DemoSimulationScenario(
        id: 'sim_deepfake_image',
        title: 'Deepfake Image Upload',
        subtitle: 'Synthetic Face Swap / Biometric Identity Spoof',
        description:
            'Simulates uploading a synthetic identity verification photo with AI face-swap artifacts and boundary gradient anomalies.',
        category: ThreatCategory.deepfake,
        icon: Icons.face_retouching_natural_rounded,
        accentColor: const Color(0xFFB388FF),
        simulatedTarget: 'biometric_face_swap_id_scan.jpg',
        threatType: 'Synthetic Identity Deepfake (GAN Face Swap)',
        riskScore: 92,
        reason:
            'Prototype forensic model detected 3.42σ facial boundary contrast variance, divergent ocular reflections, and Fourier generative micro-texture smoothing.',
        recommendedAction:
            'Reject photo for biometric identity verification. Request live dynamic challenge (blinking/turning head).',
        healthScorePenalty: -60,
        simulationSteps: const [
          'Ingesting high-resolution biometric face scan image...',
          'Running Prototype Heuristic Deepfake Model: Evaluating boundary gradients...',
          'Measuring corneal reflection angles and pupil illumination divergence...',
          'Detecting Fourier micro-texture blurring and 3.42σ GAN composite seam...',
        ],
        xaiModel: deepfakePreset,
      ),
    ];
  }
}
