package com.cyberguard.xai.presentation.scanner

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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.ContentPaste
import androidx.compose.material.icons.filled.Link
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.NoEncryption
import androidx.compose.material.icons.filled.QrCodeScanner
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cyberguard.xai.core.rules.UrlThreatDetector
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.core.theme.CyberCard
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberGlassBg
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.core.theme.RiskCritical
import com.cyberguard.xai.core.theme.RiskSafe
import com.cyberguard.xai.domain.model.UrlThreatEvaluation
import com.cyberguard.xai.presentation.components.CyberCard
import com.cyberguard.xai.presentation.components.GradientButton
import com.cyberguard.xai.presentation.components.RiskBadge

@Composable
fun UrlScannerScreen(
    onNavigateToQrScanner: () -> Unit
) {
    val clipboardManager = LocalClipboardManager.current
    var urlInput by remember { mutableStateOf("http://paypa1-account-security.top/login") }
    var evaluationResult by remember { mutableStateOf<UrlThreatEvaluation?>(UrlThreatDetector.evaluate("http://paypa1-account-security.top/login")) }

    fun runScan(input: String) {
        if (input.isNotBlank()) {
            evaluationResult = UrlThreatDetector.evaluate(input)
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        // Input Box
        CyberCard(modifier = Modifier.fillMaxWidth()) {
            Column {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "URL THREAT FORENSIC SCANNER",
                        color = CyberCyan,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )

                    Row(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(CyberGlassBg)
                            .clickable { onNavigateToQrScanner() }
                            .padding(horizontal = 8.dp, vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(imageVector = Icons.Default.QrCodeScanner, contentDescription = null, tint = CyberCyan, modifier = Modifier.size(13.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(text = "Scan QR Link", color = CyberCyan, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                OutlinedTextField(
                    value = urlInput,
                    onValueChange = {
                        urlInput = it
                        if (it.isBlank()) evaluationResult = null
                    },
                    label = { Text("Enter or paste destination URL") },
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Uri,
                        imeAction = ImeAction.Done
                    ),
                    keyboardActions = KeyboardActions(
                        onDone = { runScan(urlInput) }
                    ),
                    leadingIcon = {
                        Icon(imageVector = Icons.Default.Link, contentDescription = null, tint = CyberCyan)
                    },
                    trailingIcon = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            if (urlInput.isNotBlank()) {
                                IconButton(onClick = { urlInput = ""; evaluationResult = null }) {
                                    Icon(imageVector = Icons.Default.Clear, contentDescription = "Clear", tint = CyberTextMuted, modifier = Modifier.size(18.dp))
                                }
                            }
                            IconButton(onClick = {
                                clipboardManager.getText()?.text?.let {
                                    urlInput = it
                                    runScan(it)
                                }
                            }) {
                                Icon(imageVector = Icons.Default.ContentPaste, contentDescription = "Paste", tint = CyberCyan, modifier = Modifier.size(18.dp))
                            }
                        }
                    },
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CyberCyan,
                        unfocusedBorderColor = CyberCardBorder,
                        focusedTextColor = CyberText,
                        unfocusedTextColor = CyberText,
                        focusedLabelColor = CyberCyan,
                        unfocusedLabelColor = CyberTextMuted
                    ),
                    shape = RoundedCornerShape(12.dp)
                )

                Spacer(modifier = Modifier.height(14.dp))

                GradientButton(
                    text = "RUN URL THREAT INSPECTION",
                    onClick = { runScan(urlInput) },
                    height = 46.dp
                )
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // Demo Presets for Evaluator Testing
        Text(
            text = "TEST VECTOR SCENARIOS",
            color = CyberTextMuted,
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.sp,
            modifier = Modifier.padding(horizontal = 4.dp)
        )

        Spacer(modifier = Modifier.height(8.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            TestPresetChip(
                label = "Lookalike (paypa1)",
                modifier = Modifier.weight(1f),
                onClick = {
                    urlInput = "http://paypa1-account-security.top/login"
                    runScan(urlInput)
                }
            )

            TestPresetChip(
                label = "Raw IP Host",
                modifier = Modifier.weight(1f),
                onClick = {
                    urlInput = "http://192.168.1.100/admin/auth"
                    runScan(urlInput)
                }
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            TestPresetChip(
                label = "URL Shortener",
                modifier = Modifier.weight(1f),
                onClick = {
                    urlInput = "https://bit.ly/3xY9z-urgent-claim"
                    runScan(urlInput)
                }
            )

            TestPresetChip(
                label = "Subdomain Spoof",
                modifier = Modifier.weight(1f),
                onClick = {
                    urlInput = "https://chase.com.login.verify-identity.xyz/restore"
                    runScan(urlInput)
                }
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            TestPresetChip(
                label = "Known Threat",
                modifier = Modifier.weight(1f),
                onClick = {
                    urlInput = "http://paypa1-verify.top/auth"
                    runScan(urlInput)
                }
            )

            TestPresetChip(
                label = "Clean Safe URL",
                modifier = Modifier.weight(1f),
                onClick = {
                    urlInput = "https://www.google.com/search?q=cyberguard"
                    runScan(urlInput)
                }
            )
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Evaluation Result Display
        evaluationResult?.let { eval ->
            CyberCard(
                modifier = Modifier.fillMaxWidth(),
                borderColor = eval.severity.color.copy(alpha = 0.5f)
            ) {
                Column {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "RISK SCORE: ${eval.riskScore} / 100",
                            color = eval.severity.color,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.ExtraBold
                        )
                        RiskBadge(severity = eval.severity)
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    Text(text = "Normalized Target URL:", color = CyberTextMuted, fontSize = 11.sp)
                    Text(text = eval.normalizedUrl, color = CyberText, fontSize = 12.sp, fontWeight = FontWeight.SemiBold)

                    Spacer(modifier = Modifier.height(10.dp))

                    // Feature Indicators Strip
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        SecurityPill(
                            label = if (eval.isHttps) "HTTPS Encrypted" else "Unencrypted HTTP",
                            isWarning = !eval.isHttps,
                            icon = if (eval.isHttps) Icons.Default.Lock else Icons.Default.NoEncryption,
                            modifier = Modifier.weight(1f)
                        )
                        SecurityPill(
                            label = if (eval.isIpAddress) "IP Host URL" else "DNS Hostname",
                            isWarning = eval.isIpAddress,
                            modifier = Modifier.weight(1f)
                        )
                    }

                    if (eval.hasLookalikeDomain || eval.isShortened || eval.hasExcessiveSubdomains) {
                        Spacer(modifier = Modifier.height(6.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            if (eval.hasLookalikeDomain) {
                                SecurityPill(
                                    label = "Lookalike: ${eval.lookalikeTarget}",
                                    isWarning = true,
                                    modifier = Modifier.weight(1f)
                                )
                            }
                            if (eval.isShortened) {
                                SecurityPill(
                                    label = "Shortened Link",
                                    isWarning = true,
                                    modifier = Modifier.weight(1f)
                                )
                            }
                            if (eval.hasExcessiveSubdomains) {
                                SecurityPill(
                                    label = "${eval.subdomainCount} Subdomains",
                                    isWarning = true,
                                    modifier = Modifier.weight(1f)
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Reasons []
                    Text(text = "DETECTED REASONS (${eval.reasons.size}):", color = CyberText, fontSize = 12.sp, fontWeight = FontWeight.Bold)

                    Spacer(modifier = Modifier.height(6.dp))

                    eval.reasons.forEach { reason ->
                        Row(
                            modifier = Modifier.padding(vertical = 3.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = if (eval.riskScore >= 50) Icons.Default.Warning else Icons.Default.CheckCircle,
                                contentDescription = null,
                                tint = if (eval.riskScore >= 50) eval.severity.color else RiskSafe,
                                modifier = Modifier.size(14.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(text = reason, color = CyberText, fontSize = 11.sp, lineHeight = 16.sp)
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Recommendation
                    Text(text = "RECOMMENDATION:", color = CyberCyan, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(text = eval.recommendation, color = CyberTextMuted, fontSize = 11.sp, lineHeight = 16.sp)
                }
            }
        }
    }
}

@Composable
private fun SecurityPill(
    label: String,
    isWarning: Boolean,
    modifier: Modifier = Modifier,
    icon: androidx.compose.ui.graphics.vector.ImageVector? = null
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(8.dp))
            .background(if (isWarning) RiskCritical.copy(alpha = 0.15f) else RiskSafe.copy(alpha = 0.15f))
            .border(1.dp, if (isWarning) RiskCritical.copy(alpha = 0.35f) else RiskSafe.copy(alpha = 0.35f), RoundedCornerShape(8.dp))
            .padding(horizontal = 8.dp, vertical = 5.dp),
        contentAlignment = Alignment.Center
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            if (icon != null) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = if (isWarning) RiskCritical else RiskSafe,
                    modifier = Modifier.size(12.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
            }
            Text(
                text = label,
                color = if (isWarning) RiskCritical else RiskSafe,
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
private fun TestPresetChip(
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
