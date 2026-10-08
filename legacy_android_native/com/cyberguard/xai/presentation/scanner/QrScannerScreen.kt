package com.cyberguard.xai.presentation.scanner

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.core.Camera
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBalance
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.FlashOff
import androidx.compose.material.icons.filled.FlashOn
import androidx.compose.material.icons.filled.Link
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.OpenInBrowser
import androidx.compose.material.icons.filled.QrCodeScanner
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat
import com.cyberguard.xai.core.rules.QrThreatDetector
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.core.theme.CyberCard
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberGlassBg
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.core.theme.RiskCritical
import com.cyberguard.xai.core.theme.RiskHigh
import com.cyberguard.xai.core.theme.RiskSafe
import com.cyberguard.xai.domain.model.QrPayloadType
import com.cyberguard.xai.domain.model.QrThreatEvaluation
import com.cyberguard.xai.presentation.components.CyberCard
import com.cyberguard.xai.presentation.components.GradientButton
import com.cyberguard.xai.presentation.components.RiskBadge

@Composable
fun QrScannerScreen(
    onNavigateBack: () -> Unit
) {
    val context = LocalContext.current
    val clipboardManager = LocalClipboardManager.current

    // Camera permission state
    var hasCameraPermission by remember {
        mutableStateOf(
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED
        )
    }

    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        hasCameraPermission = isGranted
    }

    // Camera controls
    var isTorchOn by remember { mutableStateOf(false) }
    var activeCamera by remember { mutableStateOf<Camera?>(null) }

    // Evaluation State
    var evaluationResult by remember { mutableStateOf<QrThreatEvaluation?>(null) }
    var showDangerousLinkConfirmation by remember { mutableStateOf(false) }
    var pendingOpenIntentUri by remember { mutableStateOf<String?>(null) }

    // Analyzer instance
    val qrAnalyzer = remember {
        CameraQrAnalyzer { rawPayload ->
            val result = QrThreatDetector.evaluate(rawPayload)
            evaluationResult = result
        }
    }

    fun triggerScanSimulation(payload: String) {
        val result = QrThreatDetector.evaluate(payload)
        evaluationResult = result
    }

    fun handleOpenPayload(payload: String, isThreat: Boolean) {
        if (isThreat) {
            // NEVER automatically open suspicious URL - require explicit confirmation
            pendingOpenIntentUri = payload
            showDangerousLinkConfirmation = true
        } else {
            openExternalUri(context, payload)
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Top Bar
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            IconButton(
                onClick = onNavigateBack,
                modifier = Modifier
                    .clip(CircleShape)
                    .background(CyberCard)
                    .size(36.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowBack,
                    contentDescription = "Back",
                    tint = CyberCyan,
                    modifier = Modifier.size(18.dp)
                )
            }

            Text(
                text = "AI QR SCAM DEFENSE",
                color = CyberCyan,
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.2.sp
            )

            IconButton(
                onClick = {
                    isTorchOn = !isTorchOn
                    activeCamera?.cameraControl?.enableTorch(isTorchOn)
                },
                modifier = Modifier
                    .clip(CircleShape)
                    .background(if (isTorchOn) CyberPink.copy(alpha = 0.2f) else CyberCard)
                    .size(36.dp)
            ) {
                Icon(
                    imageVector = if (isTorchOn) Icons.Default.FlashOn else Icons.Default.FlashOff,
                    contentDescription = "Torch",
                    tint = if (isTorchOn) CyberPink else CyberTextMuted,
                    modifier = Modifier.size(18.dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Camera Viewfinder Box
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(290.dp)
                .clip(RoundedCornerShape(20.dp))
                .background(CyberCard)
                .border(2.dp, Brush.linearGradient(listOf(CyberCyan, CyberPink)), RoundedCornerShape(20.dp)),
            contentAlignment = Alignment.Center
        ) {
            if (hasCameraPermission) {
                CameraPreviewView(
                    analyzer = qrAnalyzer,
                    isTorchEnabled = isTorchOn,
                    onCameraReady = { cam -> activeCamera = cam }
                )

                // Reticle Overlay
                ScannerReticleOverlay()
            } else {
                // Permission Request Fallback State
                Column(
                    modifier = Modifier.padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Icon(
                        imageVector = Icons.Default.QrCodeScanner,
                        contentDescription = null,
                        tint = CyberCyan,
                        modifier = Modifier.size(64.dp)
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    Text(
                        text = "Camera Permission Required",
                        color = CyberText,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold
                    )

                    Spacer(modifier = Modifier.height(6.dp))

                    Text(
                        text = "CyberGuard inspects QR codes for malicious URLs, crypto-drainers, and deceptive UPI payment requests in real time.",
                        color = CyberTextMuted,
                        fontSize = 11.sp,
                        textAlign = TextAlign.Center,
                        lineHeight = 16.sp
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    GradientButton(
                        text = "GRANT CAMERA ACCESS",
                        onClick = { permissionLauncher.launch(Manifest.permission.CAMERA) },
                        height = 42.dp,
                        modifier = Modifier.width(220.dp)
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Test Vectors for Emulators & Demonstration
        Text(
            text = "TEST FORENSIC VECTORS",
            color = CyberTextMuted,
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.sp,
            modifier = Modifier.align(Alignment.Start).padding(horizontal = 4.dp)
        )

        Spacer(modifier = Modifier.height(8.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            TestVectorChip(
                label = "UPI Imposter Scam",
                modifier = Modifier.weight(1f),
                onClick = {
                    triggerScanSimulation("upi://pay?pa=scam-support@upi&pn=Bank%20KYC%20Validation%20Officer&am=8500&cu=INR&tn=Urgent%20KYC%20Reversal")
                }
            )

            TestVectorChip(
                label = "Phishing URL QR",
                modifier = Modifier.weight(1f),
                onClick = {
                    triggerScanSimulation("http://paypa1-account-security.top/login")
                }
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            TestVectorChip(
                label = "Malware APK Download",
                modifier = Modifier.weight(1f),
                onClick = {
                    triggerScanSimulation("https://unverified-app-store.xyz/download/update_patch.apk")
                }
            )

            TestVectorChip(
                label = "Crypto Drainer Address",
                modifier = Modifier.weight(1f),
                onClick = {
                    triggerScanSimulation("bitcoin:1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa?amount=1.2")
                }
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            TestVectorChip(
                label = "Deep-Link Intent Injection",
                modifier = Modifier.weight(1f),
                onClick = {
                    triggerScanSimulation("intent://scan/#Intent;scheme=maliciousapp;package=com.victim.app;end")
                }
            )

            TestVectorChip(
                label = "Safe Clean URL",
                modifier = Modifier.weight(1f),
                onClick = {
                    triggerScanSimulation("https://www.google.com/search?q=cyberguard")
                }
            )
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Evaluation Result Display
        evaluationResult?.let { eval ->
            val isHighThreat = eval.riskScore >= 50

            CyberCard(
                modifier = Modifier.fillMaxWidth(),
                borderColor = eval.severity.color.copy(alpha = 0.6f)
            ) {
                Column {
                    // Header Bar with Severity & Type
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = "RISK SCORE: ${eval.riskScore} / 100",
                                color = eval.severity.color,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.ExtraBold
                            )
                            Text(
                                text = "PAYLOAD: ${eval.payloadType.name}",
                                color = CyberTextMuted,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                        }
                        RiskBadge(severity = eval.severity)
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Decoded Raw Payload Box
                    Text(text = "Decoded Payload:", color = CyberTextMuted, fontSize = 11.sp)
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(8.dp))
                            .background(CyberGlassBg)
                            .padding(8.dp)
                    ) {
                        Text(
                            text = eval.rawPayload,
                            color = CyberText,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                    }

                    // Payment or Deep-Link Warning Banner
                    if (eval.isPaymentOrDeepLink) {
                        Spacer(modifier = Modifier.height(12.dp))
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(10.dp))
                                .background(RiskHigh.copy(alpha = 0.15f))
                                .border(1.dp, RiskHigh.copy(alpha = 0.4f), RoundedCornerShape(10.dp))
                                .padding(10.dp)
                        ) {
                            Column {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(
                                        imageVector = Icons.Default.Warning,
                                        contentDescription = null,
                                        tint = RiskHigh,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        text = eval.warningTitle ?: "FINANCIAL TRANSFER ALERT",
                                        color = RiskHigh,
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                }
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    text = eval.warningMessage ?: "Never authorize payments or open unknown intents without independent verification.",
                                    color = CyberText,
                                    fontSize = 11.sp,
                                    lineHeight = 15.sp
                                )

                                eval.paymentDetails?.let { details ->
                                    if (details.amount != null || details.payeeName != null) {
                                        Spacer(modifier = Modifier.height(8.dp))
                                        Text(
                                            text = "Requested Amount: ${details.currency ?: ""} ${details.amount ?: "Open Amount"}",
                                            color = CyberCyan,
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                        details.payeeName?.let { name ->
                                            Text(
                                                text = "Payee Name: $name",
                                                color = CyberTextMuted,
                                                fontSize = 11.sp
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // URL Specific Forensic Pill Strip
                    if (eval.isUrl && eval.urlEvaluation != null) {
                        Spacer(modifier = Modifier.height(10.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            ForensicPill(
                                label = if (eval.urlEvaluation.isHttps) "HTTPS Encrypted" else "Unencrypted HTTP",
                                isWarning = !eval.urlEvaluation.isHttps,
                                modifier = Modifier.weight(1f)
                            )
                            ForensicPill(
                                label = if (eval.urlEvaluation.isIpAddress) "Raw IP Host" else "Domain: ${eval.urlEvaluation.domain}",
                                isWarning = eval.urlEvaluation.isIpAddress,
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(14.dp))

                    // Threat Reasons
                    Text(
                        text = "DETECTED THREAT REASONS (${eval.reasons.size}):",
                        color = CyberText,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )

                    Spacer(modifier = Modifier.height(6.dp))

                    eval.reasons.forEach { reason ->
                        Row(
                            modifier = Modifier.padding(vertical = 3.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = if (isHighThreat) Icons.Default.Warning else Icons.Default.CheckCircle,
                                contentDescription = null,
                                tint = if (isHighThreat) eval.severity.color else RiskSafe,
                                modifier = Modifier.size(14.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = reason,
                                color = CyberText,
                                fontSize = 11.sp,
                                lineHeight = 16.sp
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(14.dp))

                    // Recommended Action
                    Text(
                        text = "RECOMMENDED ACTION:",
                        color = CyberCyan,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = eval.recommendation,
                        color = CyberTextMuted,
                        fontSize = 11.sp,
                        lineHeight = 16.sp
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    // Action Controls
                    // CRITICAL RULE: Never automatically open a suspicious URL!
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        GradientButton(
                            text = if (isHighThreat) "DISARM & DISMISS" else "RE-SCAN",
                            onClick = {
                                evaluationResult = null
                                qrAnalyzer.resumeScanning()
                            },
                            modifier = Modifier.weight(1f),
                            height = 42.dp
                        )

                        // Copy Button
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(12.dp))
                                .background(CyberCard)
                                .border(1.dp, CyberCardBorder, RoundedCornerShape(12.dp))
                                .clickable {
                                    clipboardManager.setText(AnnotatedString(eval.rawPayload))
                                    Toast.makeText(context, "Payload copied to clipboard", Toast.LENGTH_SHORT).show()
                                }
                                .padding(horizontal = 14.dp, vertical = 10.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.ContentCopy,
                                contentDescription = "Copy",
                                tint = CyberCyan,
                                modifier = Modifier.size(20.dp)
                            )
                        }

                        // Open Button (Guarded with explicit consent dialog)
                        if (eval.isUrl || eval.isPaymentOrDeepLink) {
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(if (isHighThreat) RiskCritical.copy(alpha = 0.2f) else CyberGlassBg)
                                    .border(1.dp, if (isHighThreat) RiskCritical else CyberCyan, RoundedCornerShape(12.dp))
                                    .clickable {
                                        handleOpenPayload(eval.rawPayload, isHighThreat)
                                    }
                                    .padding(horizontal = 14.dp, vertical = 10.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.OpenInBrowser,
                                    contentDescription = "Open",
                                    tint = if (isHighThreat) RiskCritical else CyberCyan,
                                    modifier = Modifier.size(20.dp)
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    // Safety Confirmation Dialog for Suspicious / Threat Links
    if (showDangerousLinkConfirmation && pendingOpenIntentUri != null) {
        AlertDialog(
            onDismissRequest = {
                showDangerousLinkConfirmation = false
                pendingOpenIntentUri = null
            },
            title = {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.Warning, contentDescription = null, tint = RiskCritical)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(text = "CRITICAL THREAT BLOCKED", color = RiskCritical, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                }
            },
            text = {
                Text(
                    text = "CyberGuard XAI detected high-severity threats in this QR payload. Opening this link may steal credentials, download malicious software, or compromise your personal safety.\n\nAre you absolutely certain you want to bypass CyberGuard protection?",
                    color = CyberText,
                    fontSize = 13.sp,
                    lineHeight = 18.sp
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        val uriToOpen = pendingOpenIntentUri ?: ""
                        showDangerousLinkConfirmation = false
                        pendingOpenIntentUri = null
                        openExternalUri(context, uriToOpen)
                    },
                    colors = ButtonDefaults.textButtonColors(contentColor = RiskCritical)
                ) {
                    Text("OVERRIDE & OPEN ANYWAY", fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                TextButton(
                    onClick = {
                        showDangerousLinkConfirmation = false
                        pendingOpenIntentUri = null
                    },
                    colors = ButtonDefaults.textButtonColors(contentColor = CyberCyan)
                ) {
                    Text("CANCEL & STAY SAFE")
                }
            },
            containerColor = CyberCard,
            shape = RoundedCornerShape(16.dp)
        )
    }
}

private fun openExternalUri(context: Context, payload: String) {
    try {
        val uri = if (!payload.startsWith("http://", ignoreCase = true) &&
            !payload.startsWith("https://", ignoreCase = true) &&
            !payload.contains("://")
        ) {
            Uri.parse("https://$payload")
        } else {
            Uri.parse(payload)
        }
        val intent = Intent(Intent.ACTION_VIEW, uri).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    } catch (e: Exception) {
        Toast.makeText(context, "No compatible application found to handle this payload.", Toast.LENGTH_LONG).show()
    }
}

@Composable
private fun ScannerReticleOverlay() {
    Box(
        modifier = Modifier
            .size(200.dp)
            .border(2.dp, CyberCyan.copy(alpha = 0.8f), RoundedCornerShape(16.dp)),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "SCANNING",
            color = CyberCyan.copy(alpha = 0.7f),
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 2.sp
        )
    }
}

@Composable
private fun ForensicPill(
    label: String,
    isWarning: Boolean,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(6.dp))
            .background(if (isWarning) RiskCritical.copy(alpha = 0.15f) else RiskSafe.copy(alpha = 0.15f))
            .border(1.dp, if (isWarning) RiskCritical.copy(alpha = 0.4f) else RiskSafe.copy(alpha = 0.4f), RoundedCornerShape(6.dp))
            .padding(horizontal = 6.dp, vertical = 4.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            color = if (isWarning) RiskCritical else RiskSafe,
            fontSize = 10.sp,
            fontWeight = FontWeight.SemiBold,
            maxLines = 1
        )
    }
}

@Composable
private fun TestVectorChip(
    label: String,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(8.dp))
            .background(CyberCard)
            .border(1.dp, CyberCardBorder, RoundedCornerShape(8.dp))
            .clickable { onClick() }
            .padding(vertical = 7.dp, horizontal = 8.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(text = label, color = CyberCyan, fontSize = 10.sp, fontWeight = FontWeight.SemiBold)
    }
}
