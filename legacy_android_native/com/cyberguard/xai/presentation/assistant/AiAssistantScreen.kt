package com.cyberguard.xai.presentation.assistant

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.AttachFile
import androidx.compose.material.icons.filled.Call
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DeleteSweep
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Link
import androidx.compose.material.icons.filled.Message
import androidx.compose.material.icons.filled.QrCode
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.SmartToy
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cyberguard.xai.core.rules.AiAssistantEngine
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.core.theme.CyberCard
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberGlassBg
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberPinkBorder
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.core.theme.RiskSafe
import com.cyberguard.xai.domain.model.AiAttachedContext
import com.cyberguard.xai.domain.model.AiChatMessage
import com.cyberguard.xai.domain.model.AiContextType
import com.cyberguard.xai.presentation.components.CyberCard
import com.cyberguard.xai.presentation.components.RiskBadge
import kotlinx.coroutines.launch
import java.util.UUID

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun AiAssistantScreen() {
    val coroutineScope = rememberCoroutineScope()
    val listState = rememberLazyListState()

    var messageInput by remember { mutableStateOf("") }
    var attachedContext by remember { mutableStateOf<AiAttachedContext?>(null) }
    var showContextPickerSheet by remember { mutableStateOf(false) }

    // Conversation History
    val conversationId = remember { UUID.randomUUID().toString() }
    val messages = remember {
        mutableStateListOf(
            AiChatMessage(
                id = "init_1",
                conversationId = conversationId,
                sender = "assistant",
                content = "Greetings. I am your CyberGuard XAI Security Copilot. Attach a suspicious message, URL, screenshot, threat ID, QR payload, or call telemetry, and ask me how to respond.",
                attachedContext = null,
                structuredResponse = null,
                timestamp = System.currentTimeMillis()
            )
        )
    }

    // Screenshot file picker
    val photoPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        if (uri != null) {
            attachedContext = AiAttachedContext(
                type = AiContextType.SCREENSHOT,
                title = "Device Screenshot",
                content = "Screenshot captured: contains remote access prompt (AnyDesk) and critical alert banner."
            )
        }
    }

    fun submitQuery(queryText: String) {
        if (queryText.isBlank()) return
        val currentContext = attachedContext

        // 1. Add User Message
        val userMsg = AiChatMessage(
            id = UUID.randomUUID().toString(),
            conversationId = conversationId,
            sender = "user",
            content = queryText.trim(),
            attachedContext = currentContext,
            structuredResponse = null,
            timestamp = System.currentTimeMillis()
        )
        messages.add(userMsg)
        messageInput = ""

        // 2. Generate Structured XAI Response
        val structured = AiAssistantEngine.generateResponse(queryText, currentContext)

        val assistantMsg = AiChatMessage(
            id = UUID.randomUUID().toString(),
            conversationId = conversationId,
            sender = "assistant",
            content = structured.explanation,
            attachedContext = currentContext,
            structuredResponse = structured,
            timestamp = System.currentTimeMillis()
        )
        messages.add(assistantMsg)

        coroutineScope.launch {
            listState.animateScrollToItem(messages.size - 1)
        }
    }

    val quickQuestions = listOf(
        "Is this safe?",
        "Why is this suspicious?",
        "What should I do?",
        "How serious is this?",
        "How can I verify this?"
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
    ) {
        // Top Bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(CyberCard)
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .size(34.dp)
                        .clip(CircleShape)
                        .background(CyberGlassBg)
                        .border(1.dp, CyberCyan, CircleShape)
                ) {
                    Icon(imageVector = Icons.Default.SmartToy, contentDescription = null, tint = CyberCyan, modifier = Modifier.size(20.dp))
                }
                Spacer(modifier = Modifier.width(10.dp))
                Column {
                    Text(text = "CYBERGUARD XAI COPILOT", color = CyberCyan, fontSize = 12.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
                    Text(
                        text = if (attachedContext != null) "Context Active: ${attachedContext?.type?.title}" else "Ready for Threat Telemetry",
                        color = if (attachedContext != null) CyberPink else CyberTextMuted,
                        fontSize = 10.sp
                    )
                }
            }

            IconButton(
                onClick = {
                    messages.clear()
                    attachedContext = null
                    messages.add(
                        AiChatMessage(
                            id = UUID.randomUUID().toString(),
                            conversationId = conversationId,
                            sender = "assistant",
                            content = "New session started. Attach suspicious telemetry below for forensic investigation.",
                            timestamp = System.currentTimeMillis()
                        )
                    )
                }
            ) {
                Icon(imageVector = Icons.Default.DeleteSweep, contentDescription = "Clear Session", tint = CyberTextMuted, modifier = Modifier.size(20.dp))
            }
        }

        // Active Context Banner (If attached)
        AnimatedVisibility(visible = attachedContext != null) {
            attachedContext?.let { ctx ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(CyberPink.copy(alpha = 0.12f))
                        .border(1.dp, CyberPink.copy(alpha = 0.3f))
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(
                        modifier = Modifier.weight(1f),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(imageVector = getContextIcon(ctx.type), contentDescription = null, tint = CyberPink, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Column {
                            Text(text = "ATTACHED: ${ctx.type.title.uppercase()}", color = CyberPink, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                            Text(text = ctx.preview, color = CyberText, fontSize = 11.sp, maxLines = 1)
                        }
                    }

                    IconButton(
                        onClick = { attachedContext = null },
                        modifier = Modifier.size(24.dp)
                    ) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = "Remove", tint = CyberPink, modifier = Modifier.size(16.dp))
                    }
                }
            }
        }

        // Messages Stream
        LazyColumn(
            state = listState,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            items(messages) { msg ->
                val isUser = msg.sender == "user"
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = if (isUser) Arrangement.End else Arrangement.Start
                ) {
                    if (!isUser) {
                        Box(
                            contentAlignment = Alignment.Center,
                            modifier = Modifier
                                .size(28.dp)
                                .clip(CircleShape)
                                .background(CyberGlassBg)
                                .border(1.dp, CyberCyan, CircleShape)
                        ) {
                            Icon(imageVector = Icons.Default.SmartToy, contentDescription = null, tint = CyberCyan, modifier = Modifier.size(16.dp))
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                    }

                    if (isUser) {
                        // User Bubble
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(16.dp))
                                .background(CyberPink.copy(alpha = 0.2f))
                                .border(1.dp, CyberPinkBorder, RoundedCornerShape(16.dp))
                                .padding(12.dp)
                                .widthIn(max = 280.dp)
                        ) {
                            Column {
                                if (msg.attachedContext != null) {
                                    Text(
                                        text = "Ref: ${msg.attachedContext.type.title}",
                                        color = CyberPink,
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                }
                                Text(text = msg.content, color = CyberText, fontSize = 13.sp, lineHeight = 18.sp)
                            }
                        }
                    } else if (msg.structuredResponse != null) {
                        // Structured AI Assistant Response Card
                        val structured = msg.structuredResponse
                        CyberCard(
                            modifier = Modifier.fillMaxWidth(0.92f),
                            borderColor = structured.severity.color.copy(alpha = 0.5f)
                        ) {
                            Column {
                                // Header Strip with Risk & Confidence
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(
                                        text = structured.risk,
                                        color = structured.severity.color,
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.ExtraBold
                                    )
                                    RiskBadge(severity = structured.severity)
                                }

                                Spacer(modifier = Modifier.height(6.dp))

                                // Confidence Metric
                                Text(
                                    text = "Model Confidence: ${structured.confidence}",
                                    color = if (!structured.isCertaintyClaimed) CyberPink else CyberCyan,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.SemiBold
                                )

                                Spacer(modifier = Modifier.height(10.dp))

                                // Evidence Section
                                Text(
                                    text = "FORENSIC EVIDENCE:",
                                    color = CyberText,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold
                                )
                                Spacer(modifier = Modifier.height(4.dp))
                                structured.evidence.forEach { ev ->
                                    Row(
                                        modifier = Modifier.padding(vertical = 2.dp),
                                        verticalAlignment = Alignment.Top
                                    ) {
                                        Icon(
                                            imageVector = if (structured.severity.ordinal >= 2) Icons.Default.Warning else Icons.Default.CheckCircle,
                                            contentDescription = null,
                                            tint = structured.severity.color,
                                            modifier = Modifier.size(13.dp).padding(top = 2.dp)
                                        )
                                        Spacer(modifier = Modifier.width(6.dp))
                                        Text(text = ev, color = CyberText, fontSize = 11.sp, lineHeight = 15.sp)
                                    }
                                }

                                Spacer(modifier = Modifier.height(10.dp))

                                // Explanation Section
                                Text(
                                    text = "XAI EXPLANATION:",
                                    color = CyberCyan,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold
                                )
                                Spacer(modifier = Modifier.height(3.dp))
                                Text(
                                    text = structured.explanation,
                                    color = CyberTextMuted,
                                    fontSize = 11.sp,
                                    lineHeight = 16.sp
                                )

                                Spacer(modifier = Modifier.height(10.dp))

                                // Recommended Action
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(8.dp))
                                        .background(CyberGlassBg)
                                        .border(1.dp, CyberCardBorder, RoundedCornerShape(8.dp))
                                        .padding(8.dp)
                                ) {
                                    Column {
                                        Text(
                                            text = "RECOMMENDED ACTION:",
                                            color = CyberPink,
                                            fontSize = 10.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                        Spacer(modifier = Modifier.height(2.dp))
                                        Text(
                                            text = structured.recommendedAction,
                                            color = CyberText,
                                            fontSize = 11.sp,
                                            lineHeight = 15.sp
                                        )
                                    }
                                }
                            }
                        }
                    } else {
                        // Plain Introductory Assistant Message
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(16.dp))
                                .background(CyberCard)
                                .border(1.dp, CyberCardBorder, RoundedCornerShape(16.dp))
                                .padding(12.dp)
                                .widthIn(max = 280.dp)
                        ) {
                            Text(text = msg.content, color = CyberText, fontSize = 13.sp, lineHeight = 18.sp)
                        }
                    }
                }
            }
        }

        // Quick Prompt Question Chips
        FlowRow(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 6.dp),
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            quickQuestions.forEach { question ->
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(14.dp))
                        .background(CyberCard)
                        .border(1.dp, CyberCardBorder, RoundedCornerShape(14.dp))
                        .clickable { submitQuery(question) }
                        .padding(horizontal = 10.dp, vertical = 5.dp)
                ) {
                    Text(text = question, color = CyberCyan, fontSize = 11.sp, fontWeight = FontWeight.SemiBold)
                }
            }
        }

        // Input & Attachment Controls
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(CyberCard)
                .padding(horizontal = 10.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Attachment Button
            IconButton(
                onClick = { showContextPickerSheet = true },
                modifier = Modifier
                    .size(38.dp)
                    .clip(CircleShape)
                    .background(if (attachedContext != null) CyberPink.copy(alpha = 0.2f) else CyberGlassBg)
            ) {
                Icon(
                    imageVector = Icons.Default.AttachFile,
                    contentDescription = "Attach Context",
                    tint = if (attachedContext != null) CyberPink else CyberCyan,
                    modifier = Modifier.size(19.dp)
                )
            }

            Spacer(modifier = Modifier.width(6.dp))

            OutlinedTextField(
                value = messageInput,
                onValueChange = { messageInput = it },
                placeholder = {
                    Text(
                        text = if (attachedContext != null) "Ask about attached ${attachedContext?.type?.title}..." else "Ask cybersecurity question...",
                        color = CyberTextMuted,
                        fontSize = 12.sp
                    )
                },
                singleLine = true,
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Send),
                keyboardActions = KeyboardActions(onSend = { submitQuery(messageInput) }),
                modifier = Modifier.weight(1f),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CyberCyan,
                    unfocusedBorderColor = CyberCardBorder,
                    focusedTextColor = CyberText,
                    unfocusedTextColor = CyberText
                ),
                shape = RoundedCornerShape(20.dp)
            )

            Spacer(modifier = Modifier.width(6.dp))

            IconButton(
                onClick = { submitQuery(messageInput) },
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(Brush.horizontalGradient(listOf(CyberCyan, CyberPink)))
            ) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.Send,
                    contentDescription = "Send",
                    tint = CyberBackground,
                    modifier = Modifier.size(18.dp)
                )
            }
        }
    }

    // Modal Context Picker Bottom Sheet
    if (showContextPickerSheet) {
        val sheetState = rememberModalBottomSheetState()
        ModalBottomSheet(
            onDismissRequest = { showContextPickerSheet = false },
            sheetState = sheetState,
            containerColor = CyberCard,
            shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "ATTACH THREAT CONTEXT FOR AI COPILOT",
                    color = CyberCyan,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                )
                Spacer(modifier = Modifier.height(14.dp))

                ContextOptionItem(
                    icon = Icons.Default.Message,
                    title = "Pasted Message",
                    description = "Analyze SMS, WhatsApp, or Telegram message for phishing and urgent payment demands",
                    onClick = {
                        attachedContext = AiAttachedContext(
                            type = AiContextType.PASTED_MESSAGE,
                            title = "Pasted SMS Text",
                            content = "URGENT: Your bank account is suspended immediately. Send your 6-digit OTP code to unlock."
                        )
                        showContextPickerSheet = false
                    }
                )

                ContextOptionItem(
                    icon = Icons.Default.Link,
                    title = "Target URL",
                    description = "Evaluate destination URL against lookalike heuristics, TLDs, and blacklists",
                    onClick = {
                        attachedContext = AiAttachedContext(
                            type = AiContextType.URL,
                            title = "Target URL",
                            content = "http://paypa1-account-security.top/login"
                        )
                        showContextPickerSheet = false
                    }
                )

                ContextOptionItem(
                    icon = Icons.Default.Image,
                    title = "Screenshot Forensic",
                    description = "Upload screen capture to detect tech-support scams, fake virus scares, or remote access apps",
                    onClick = {
                        showContextPickerSheet = false
                        photoPickerLauncher.launch("image/*")
                    }
                )

                ContextOptionItem(
                    icon = Icons.Default.QrCode,
                    title = "QR Code Result",
                    description = "Inspect decoded QR payload for UPI imposter schemes, crypto drainers, and APK downloads",
                    onClick = {
                        attachedContext = AiAttachedContext(
                            type = AiContextType.QR_RESULT,
                            title = "Decoded QR Payload",
                            content = "upi://pay?pa=scam-support@upi&pn=Bank%20KYC%20Validation&am=5000"
                        )
                        showContextPickerSheet = false
                    }
                )

                ContextOptionItem(
                    icon = Icons.Default.Call,
                    title = "Call Risk Result",
                    description = "Incorporate VoIP carrier anomalies, audio synthesis, and community reports",
                    onClick = {
                        attachedContext = AiAttachedContext(
                            type = AiContextType.CALL_RISK,
                            title = "Incoming Call Telemetry",
                            content = "+1-800-424-9098",
                            metadata = mapOf(
                                "riskScore" to "85",
                                "reasons" to "VoIP origin;IRS imposter report;Synthetic voice clone"
                            )
                        )
                        showContextPickerSheet = false
                    }
                )

                ContextOptionItem(
                    icon = Icons.Default.Security,
                    title = "Threat Event ID",
                    description = "Query active quarantine records from the security_events database",
                    onClick = {
                        attachedContext = AiAttachedContext(
                            type = AiContextType.THREAT_ID,
                            title = "Incident Record",
                            content = "THREAT-C2-8821"
                        )
                        showContextPickerSheet = false
                    }
                )

                Spacer(modifier = Modifier.height(20.dp))
            }
        }
    }
}

@Composable
private fun ContextOptionItem(
    icon: ImageVector,
    title: String,
    description: String,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .clickable { onClick() }
            .padding(vertical = 10.dp, horizontal = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(38.dp)
                .clip(CircleShape)
                .background(CyberGlassBg)
                .border(1.dp, CyberCyan.copy(alpha = 0.5f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = icon, contentDescription = null, tint = CyberCyan, modifier = Modifier.size(18.dp))
        }

        Spacer(modifier = Modifier.width(12.dp))

        Column {
            Text(text = title, color = CyberText, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
            Text(text = description, color = CyberTextMuted, fontSize = 11.sp, lineHeight = 15.sp)
        }
    }
}

private fun getContextIcon(type: AiContextType): ImageVector {
    return when (type) {
        AiContextType.PASTED_MESSAGE -> Icons.Default.Message
        AiContextType.URL -> Icons.Default.Link
        AiContextType.SCREENSHOT -> Icons.Default.Image
        AiContextType.THREAT_ID -> Icons.Default.Security
        AiContextType.QR_RESULT -> Icons.Default.QrCode
        AiContextType.CALL_RISK -> Icons.Default.Call
        AiContextType.NONE -> Icons.Default.SmartToy
    }
}
