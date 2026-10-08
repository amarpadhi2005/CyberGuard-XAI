package com.cyberguard.xai.presentation.score

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateContentSize
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
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
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Block
import androidx.compose.material.icons.filled.Call
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.ExpandLess
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Link
import androidx.compose.material.icons.filled.NotificationsActive
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.School
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.core.theme.CyberCard
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.core.theme.RiskCritical
import com.cyberguard.xai.core.theme.RiskMedium
import com.cyberguard.xai.core.theme.RiskSafe
import com.cyberguard.xai.domain.model.FactorCategory
import com.cyberguard.xai.domain.model.FactorStatus
import com.cyberguard.xai.domain.model.ScoreDeltaEvent
import com.cyberguard.xai.domain.model.ScoreFactor
import com.cyberguard.xai.domain.model.TransparentRule
import com.cyberguard.xai.presentation.components.CyberCard
import com.cyberguard.xai.presentation.components.GradientButton
import com.cyberguard.xai.presentation.components.SecurityScore

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SecurityScoreScreen(
    onNavigateBack: () -> Unit,
    viewModel: SecurityScoreViewModel = viewModel(factory = SecurityScoreViewModel.provideFactory())
) {
    val uiState by viewModel.uiState.collectAsState()
    val snackbarHostState = remember { SnackbarHostState() }
    var expandedFactorCategory by remember { mutableStateOf<FactorCategory?>(null) }
    val rulesSheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val historySheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    LaunchedEffect(uiState.feedbackMessage) {
        uiState.feedbackMessage?.let {
            snackbarHostState.showSnackbar(it)
            viewModel.onEvent(ScoreUiEvent.ClearFeedback)
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Top Navigation & Action Bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 12.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                IconButton(
                    onClick = onNavigateBack,
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(CyberCard)
                ) {
                    Icon(
                        imageVector = Icons.Default.ArrowBack,
                        contentDescription = "Back",
                        tint = CyberCyan
                    )
                }

                Text(
                    text = "PERSONAL SECURITY SCORE",
                    color = CyberText,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 1.2.sp
                )

                Row {
                    IconButton(
                        onClick = { viewModel.onEvent(ScoreUiEvent.ShowHistory(true)) },
                        modifier = Modifier
                            .size(40.dp)
                            .clip(CircleShape)
                            .background(CyberCard)
                    ) {
                        Icon(
                            imageVector = Icons.Default.History,
                            contentDescription = "Score History",
                            tint = CyberCyan
                        )
                    }

                    Spacer(modifier = Modifier.width(8.dp))

                    IconButton(
                        onClick = { viewModel.onEvent(ScoreUiEvent.ShowRules(true)) },
                        modifier = Modifier
                            .size(40.dp)
                            .clip(CircleShape)
                            .background(CyberCard)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Info,
                            contentDescription = "Scoring Rules Rubric",
                            tint = CyberPink
                        )
                    }
                }
            }

            val scoreObj = uiState.score
            val currentScore = scoreObj?.overallScore ?: 88
            val currentGrade = scoreObj?.grade ?: "A"
            val postureTitle = scoreObj?.postureTitle ?: "Evaluating Telemetry..."
            val postureDesc = scoreObj?.postureDescription ?: "Computing defense factors across active interceptors."

            // Main Hero Radial Score Card
            CyberCard(
                modifier = Modifier.fillMaxWidth(),
                gradientBorder = Brush.linearGradient(listOf(CyberCyan.copy(alpha = 0.6f), CyberPink.copy(alpha = 0.4f)))
            ) {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    SecurityScore(
                        score = currentScore,
                        grade = currentGrade,
                        label = "AGGREGATED SCORE"
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.Center
                    ) {
                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = when {
                                currentScore >= 85 -> RiskSafe.copy(alpha = 0.15f)
                                currentScore >= 70 -> CyberCyan.copy(alpha = 0.15f)
                                currentScore >= 50 -> RiskMedium.copy(alpha = 0.15f)
                                else -> RiskCritical.copy(alpha = 0.15f)
                            },
                            border = BorderStroke(
                                1.dp,
                                when {
                                    currentScore >= 85 -> RiskSafe
                                    currentScore >= 70 -> CyberCyan
                                    currentScore >= 50 -> RiskMedium
                                    else -> RiskCritical
                                }
                            )
                        ) {
                            Text(
                                text = "GRADE $currentGrade  •  $postureTitle",
                                color = when {
                                    currentScore >= 85 -> RiskSafe
                                    currentScore >= 70 -> CyberCyan
                                    currentScore >= 50 -> RiskMedium
                                    else -> RiskCritical
                                },
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    Text(
                        text = postureDesc,
                        color = CyberTextMuted,
                        fontSize = 12.sp,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(horizontal = 16.dp)
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .clip(RoundedCornerShape(20.dp))
                            .background(CyberBackground.copy(alpha = 0.6f))
                            .padding(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(8.dp)
                                .clip(CircleShape)
                                .background(RiskSafe)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "TRANSPARENT MATHEMATICAL EVALUATION (0-100)",
                            color = RiskSafe,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 0.8.sp
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // ==================================================================
            // "SHOW USERS WHY THEIR SCORE CHANGED" - Spotlight Recent Delta Card
            // ==================================================================
            val latestDelta = uiState.scoreHistory.firstOrNull()
            if (latestDelta != null) {
                LatestScoreChangeCard(
                    delta = latestDelta,
                    onViewFullHistory = { viewModel.onEvent(ScoreUiEvent.ShowHistory(true)) }
                )
                Spacer(modifier = Modifier.height(18.dp))
            }

            // Section Header: Transparent Factors Breakdown
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 4.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "TRANSPARENT FACTOR BREAKDOWN",
                    color = CyberTextMuted,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.1.sp
                )
                Text(
                    text = "7 FACTORS  •  100 PTS MAX",
                    color = CyberCyan,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            // The 7 Required Factor Cards
            val factorsList = scoreObj?.factors ?: emptyList()
            factorsList.forEach { factor ->
                val isExpanded = expandedFactorCategory == factor.category
                ExpandableFactorCard(
                    factor = factor,
                    isExpanded = isExpanded,
                    onToggleExpand = {
                        expandedFactorCategory = if (isExpanded) null else factor.category
                    },
                    onRuleActionClick = { rule ->
                        handleRuleAction(rule, viewModel)
                    }
                )
                Spacer(modifier = Modifier.height(10.dp))
            }

            Spacer(modifier = Modifier.height(12.dp))

            // ==================================================================
            // ACTIONABLE WAYS TO REACH 100 PTS
            // ==================================================================
            Text(
                text = "ACTIONABLE SCORE RECOVERY & BOOSTS",
                color = CyberTextMuted,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.1.sp,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 4.dp)
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Interactive Training Simulator (Module 4 completion demo)
            val incompleteModule = uiState.trainingModules.firstOrNull { !it.isCompleted }
            if (incompleteModule != null) {
                CyberCard(
                    modifier = Modifier.fillMaxWidth(),
                    borderColor = CyberCyan
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(
                                    imageVector = Icons.Default.School,
                                    contentDescription = null,
                                    tint = CyberCyan,
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "QUIZ AVAILABLE (+${incompleteModule.pointsReward} PTS)",
                                    color = CyberCyan,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = incompleteModule.title,
                                color = CyberText,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Spacer(modifier = Modifier.height(2.dp))
                            Text(
                                text = incompleteModule.description,
                                color = CyberTextMuted,
                                fontSize = 11.sp
                            )
                        }

                        Spacer(modifier = Modifier.width(12.dp))

                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = CyberCyan,
                            modifier = Modifier.clickable {
                                viewModel.onEvent(ScoreUiEvent.CompleteTraining(incompleteModule.moduleIndex))
                            }
                        ) {
                            Text(
                                text = "COMPLETE",
                                color = CyberBackground,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.ExtraBold,
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp)
                            )
                        }
                    }
                }
                Spacer(modifier = Modifier.height(10.dp))
            }

            // General Recalculation Button
            GradientButton(
                text = "SYNCHRONIZE & RE-CALCULATE SCORE",
                icon = Icons.Default.Refresh,
                isLoading = uiState.isLoading,
                onClick = { viewModel.onEvent(ScoreUiEvent.Recalculate) }
            )

            Spacer(modifier = Modifier.height(24.dp))
        }

        SnackbarHost(
            hostState = snackbarHostState,
            modifier = Modifier.align(Alignment.BottomCenter)
        )

        // ==================================================================
        // BOTTOM SHEET: "WHY DID MY SCORE CHANGE?" Full Audit History
        // ==================================================================
        if (uiState.showHistoryModal) {
            ModalBottomSheet(
                onDismissRequest = { viewModel.onEvent(ScoreUiEvent.ShowHistory(false)) },
                sheetState = historySheetState,
                containerColor = CyberCard,
                dragHandle = {
                    Box(
                        modifier = Modifier
                            .padding(vertical = 10.dp)
                            .size(width = 40.dp, height = 4.dp)
                            .clip(RoundedCornerShape(2.dp))
                            .background(CyberTextMuted.copy(alpha = 0.5f))
                    )
                }
            ) {
                ScoreHistoryBottomSheetContent(
                    history = uiState.scoreHistory,
                    onClose = { viewModel.onEvent(ScoreUiEvent.ShowHistory(false)) }
                )
            }
        }

        // ==================================================================
        // BOTTOM SHEET: TRANSPARENT SCORING RULES RUBRIC
        // ==================================================================
        if (uiState.showRulesModal) {
            ModalBottomSheet(
                onDismissRequest = { viewModel.onEvent(ScoreUiEvent.ShowRules(false)) },
                sheetState = rulesSheetState,
                containerColor = CyberCard,
                dragHandle = {
                    Box(
                        modifier = Modifier
                            .padding(vertical = 10.dp)
                            .size(width = 40.dp, height = 4.dp)
                            .clip(RoundedCornerShape(2.dp))
                            .background(CyberTextMuted.copy(alpha = 0.5f))
                    )
                }
            ) {
                TransparentRulesRubricContent(
                    onClose = { viewModel.onEvent(ScoreUiEvent.ShowRules(false)) }
                )
            }
        }
    }
}

// ==========================================================================
// Component: Latest Score Change Highlight ("Why Your Score Changed")
// ==========================================================================
@Composable
private fun LatestScoreChangeCard(
    delta: ScoreDeltaEvent,
    onViewFullHistory: () -> Unit
) {
    CyberCard(
        modifier = Modifier.fillMaxWidth(),
        borderColor = if (delta.isPositive) RiskSafe else CyberPink
    ) {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(32.dp)
                            .clip(CircleShape)
                            .background(if (delta.isPositive) RiskSafe.copy(alpha = 0.15f) else CyberPink.copy(alpha = 0.15f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = if (delta.isPositive) Icons.Default.ArrowUpward else Icons.Default.ArrowDownward,
                            contentDescription = null,
                            tint = if (delta.isPositive) RiskSafe else CyberPink,
                            modifier = Modifier.size(18.dp)
                        )
                    }

                    Spacer(modifier = Modifier.width(10.dp))

                    Column {
                        Text(
                            text = "WHY DID MY SCORE CHANGE?",
                            color = CyberTextMuted,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.ExtraBold,
                            letterSpacing = 1.sp
                        )
                        Text(
                            text = delta.triggerTitle,
                            color = CyberText,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }

                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = if (delta.isPositive) RiskSafe else CyberPink
                ) {
                    Text(
                        text = delta.deltaDisplay,
                        color = CyberBackground,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.ExtraBold,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            HorizontalDivider(color = CyberCardBorder)

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = delta.reasonExplanation,
                color = CyberText,
                fontSize = 12.sp,
                lineHeight = 17.sp
            )

            if (delta.remediationAction != null) {
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "Recommendation: ${delta.remediationAction}",
                    color = CyberCyan,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Event recorded: ${delta.timestamp}",
                    color = CyberTextMuted,
                    fontSize = 10.sp
                )

                Text(
                    text = "View Audit History →",
                    color = CyberCyan,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.clickable { onViewFullHistory() }
                )
            }
        }
    }
}

// ==========================================================================
// Component: Expandable Factor Card with Transparent Rules
// ==========================================================================
@Composable
private fun ExpandableFactorCard(
    factor: ScoreFactor,
    isExpanded: Boolean,
    onToggleExpand: () -> Unit,
    onRuleActionClick: (TransparentRule) -> Unit
) {
    val factorIcon = when (factor.category) {
        FactorCategory.CALL_PROTECTION -> Icons.Default.Call
        FactorCategory.NOTIFICATION_PROTECTION -> Icons.Default.NotificationsActive
        FactorCategory.SECURITY_SETTINGS -> Icons.Default.Shield
        FactorCategory.USER_TRAINING -> Icons.Default.School
        FactorCategory.THREAT_EVENTS -> Icons.Default.Warning
        FactorCategory.DANGEROUS_LINKS -> Icons.Default.Link
        FactorCategory.BLOCKED_CALLS -> Icons.Default.Block
        FactorCategory.SYSTEM_RECALCULATION -> Icons.Default.Refresh
    }

    val statusColor = when (factor.status) {
        FactorStatus.OPTIMAL -> RiskSafe
        FactorStatus.WARNING -> RiskMedium
        FactorStatus.CRITICAL -> RiskCritical
    }

    CyberCard(
        modifier = Modifier
            .fillMaxWidth()
            .animateContentSize()
            .clickable { onToggleExpand() },
        borderColor = if (isExpanded) CyberCyan else CyberCardBorder
    ) {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(CyberBackground),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = factorIcon,
                        contentDescription = null,
                        tint = CyberCyan,
                        modifier = Modifier.size(20.dp)
                    )
                }

                Spacer(modifier = Modifier.width(12.dp))

                Column(modifier = Modifier.weight(1f)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = factor.name,
                            color = CyberText,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold
                        )

                        Text(
                            text = "${factor.currentPoints} / ${factor.maxPoints} pts",
                            color = if (factor.currentPoints == factor.maxPoints) RiskSafe else CyberCyan,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.ExtraBold
                        )
                    }

                    Spacer(modifier = Modifier.height(4.dp))

                    Text(
                        text = factor.summary,
                        color = CyberTextMuted,
                        fontSize = 11.sp
                    )

                    Spacer(modifier = Modifier.height(6.dp))

                    LinearProgressIndicator(
                        progress = { factor.percentage },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(6.dp)
                            .clip(RoundedCornerShape(3.dp)),
                        color = statusColor,
                        trackColor = CyberBackground
                    )
                }

                Spacer(modifier = Modifier.width(8.dp))

                Icon(
                    imageVector = if (isExpanded) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                    contentDescription = null,
                    tint = CyberTextMuted,
                    modifier = Modifier.size(20.dp)
                )
            }

            AnimatedVisibility(
                visible = isExpanded,
                enter = fadeIn() + expandVertically(),
                exit = fadeOut() + shrinkVertically()
            ) {
                Column(modifier = Modifier.padding(top = 14.dp)) {
                    HorizontalDivider(color = CyberCardBorder)
                    Spacer(modifier = Modifier.height(10.dp))

                    Text(
                        text = "TRANSPARENT SCORING RULES (${factor.rules.size} RULES)",
                        color = CyberTextMuted,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = 1.sp
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    factor.rules.forEach { rule ->
                        SubRuleItemRow(rule = rule, onActionClick = { onRuleActionClick(rule) })
                        Spacer(modifier = Modifier.height(8.dp))
                    }
                }
            }
        }
    }
}

@Composable
private fun SubRuleItemRow(
    rule: TransparentRule,
    onActionClick: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(10.dp),
        color = CyberBackground,
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(10.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.weight(1f)) {
                    Icon(
                        imageVector = if (rule.isSatisfied) Icons.Default.CheckCircle else Icons.Default.Warning,
                        contentDescription = null,
                        tint = if (rule.isSatisfied) RiskSafe else RiskCritical,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = rule.title,
                        color = CyberText,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                Surface(
                    shape = RoundedCornerShape(6.dp),
                    color = if (rule.isSatisfied) RiskSafe.copy(alpha = 0.2f) else RiskCritical.copy(alpha = 0.2f)
                ) {
                    Text(
                        text = "${rule.pointsAwarded}/${rule.maxPoints} pts",
                        color = if (rule.isSatisfied) RiskSafe else RiskCritical,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = rule.explanation,
                color = CyberTextMuted,
                fontSize = 11.sp
            )

            if (!rule.isSatisfied && rule.remediationAction != null) {
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "ACTION: ${rule.remediationAction}",
                    color = CyberCyan,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.ExtraBold,
                    modifier = Modifier
                        .clickable { onActionClick() }
                        .padding(vertical = 2.dp)
                )
            }
        }
    }
}

// ==========================================================================
// BottomSheet: Score Change History Timeline
// ==========================================================================
@Composable
private fun ScoreHistoryBottomSheetContent(
    history: List<ScoreDeltaEvent>,
    onClose: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(20.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = "SCORE CHANGE AUDIT TRAIL",
                    color = CyberText,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.ExtraBold
                )
                Text(
                    text = "Every factor delta is verified and explainable",
                    color = CyberTextMuted,
                    fontSize = 11.sp
                )
            }

            IconButton(onClick = onClose) {
                Icon(imageVector = Icons.Default.Close, contentDescription = "Close", tint = CyberTextMuted)
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        if (history.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(32.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(text = "No score fluctuations recorded yet.", color = CyberTextMuted, fontSize = 12.sp)
            }
        } else {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
            ) {
                history.forEach { item ->
                    CyberCard(
                        modifier = Modifier.fillMaxWidth(),
                        borderColor = if (item.isPositive) RiskSafe else CyberPink
                    ) {
                        Column {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Surface(
                                        shape = RoundedCornerShape(6.dp),
                                        color = if (item.isPositive) RiskSafe else CyberPink
                                    ) {
                                        Text(
                                            text = item.deltaDisplay,
                                            color = CyberBackground,
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.ExtraBold,
                                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                                        )
                                    }
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text(
                                        text = "${item.previousScore} → ${item.newScore}",
                                        color = CyberTextMuted,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                }

                                Text(
                                    text = item.timestamp,
                                    color = CyberTextMuted,
                                    fontSize = 10.sp
                                )
                            }

                            Spacer(modifier = Modifier.height(6.dp))

                            Text(
                                text = item.triggerTitle,
                                color = CyberText,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold
                            )

                            Spacer(modifier = Modifier.height(4.dp))

                            Text(
                                text = item.reasonExplanation,
                                color = CyberTextMuted,
                                fontSize = 11.sp,
                                lineHeight = 16.sp
                            )
                        }
                    }
                    Spacer(modifier = Modifier.height(10.dp))
                }
            }
        }
    }
}

// ==========================================================================
// BottomSheet: Transparent Scoring Rubric
// ==========================================================================
@Composable
private fun TransparentRulesRubricContent(
    onClose: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(20.dp)
            .verticalScroll(rememberScrollState())
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = "TRANSPARENT SCORING RULES",
                    color = CyberText,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.ExtraBold
                )
                Text(
                    text = "Mathematical formula and 100-point rubric",
                    color = CyberTextMuted,
                    fontSize = 11.sp
                )
            }

            IconButton(onClick = onClose) {
                Icon(imageVector = Icons.Default.Close, contentDescription = "Close", tint = CyberTextMuted)
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        Surface(
            shape = RoundedCornerShape(10.dp),
            color = CyberBackground,
            border = BorderStroke(1.dp, CyberCardBorder),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(12.dp)) {
                Text(
                    text = "MATHEMATICAL FORMULA",
                    color = CyberCyan,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "Score = Clamp(0, 100, Σ Factors)",
                    color = CyberText,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.ExtraBold
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "No hidden penalties or subjective AI hallucinations. Every point is mapped directly to a measurable security interceptor or action.",
                    color = CyberTextMuted,
                    fontSize = 11.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        val rubricItems = listOf(
            Triple("1. Call Protection", "15 pts", "Screening active (+10 pts) • Auto-block high risk (+5 pts)"),
            Triple("2. Notification Protection", "15 pts", "SMS/App listener active (+10 pts) • Scam token NLP sniffer (+5 pts)"),
            Triple("3. Security Settings", "15 pts", "Biometric lock (+5 pts) • Floating HUD (+5 pts) • Privacy telemetry (+5 pts)"),
            Triple("4. User Training Completion", "15 pts", "4 modules certified (+4, +4, +4, +3 pts)"),
            Triple("5. Recent Threat Events", "15 pts", "Clean baseline: 15 pts. Critical threat: -8 pts. Warning: -4 pts."),
            Triple("6. Dangerous Links Posture", "15 pts", "Zero malicious URLs (30d): +10 pts. Pre-flight URL scanner: +5 pts."),
            Triple("7. Blocked Calls & Efficacy", "10 pts", "Carrier scam blocklist: +5 pts. Intercept efficacy verified: +5 pts.")
        )

        rubricItems.forEach { (name, maxPts, breakdown) ->
            Surface(
                shape = RoundedCornerShape(8.dp),
                color = CyberBackground,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(10.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(text = name, color = CyberText, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(text = breakdown, color = CyberTextMuted, fontSize = 10.sp)
                    }
                    Text(text = maxPts, color = CyberCyan, fontSize = 12.sp, fontWeight = FontWeight.ExtraBold)
                }
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        Text(
            text = "Total Max Points: 15 + 15 + 15 + 15 + 15 + 15 + 10 = 100 PTS",
            color = RiskSafe,
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth()
        )
    }
}

private fun handleRuleAction(rule: TransparentRule, viewModel: SecurityScoreViewModel) {
    when (rule.factorCategory) {
        FactorCategory.CALL_PROTECTION -> viewModel.onEvent(ScoreUiEvent.ToggleProtection(FactorCategory.CALL_PROTECTION, true))
        FactorCategory.NOTIFICATION_PROTECTION -> viewModel.onEvent(ScoreUiEvent.ToggleProtection(FactorCategory.NOTIFICATION_PROTECTION, true))
        FactorCategory.SECURITY_SETTINGS -> viewModel.onEvent(ScoreUiEvent.ToggleProtection(FactorCategory.SECURITY_SETTINGS, true))
        FactorCategory.USER_TRAINING -> viewModel.onEvent(ScoreUiEvent.CompleteTraining(4))
        FactorCategory.THREAT_EVENTS -> viewModel.onEvent(ScoreUiEvent.ResolveThreat("CRITICAL"))
        FactorCategory.DANGEROUS_LINKS -> viewModel.onEvent(ScoreUiEvent.ToggleProtection(FactorCategory.DANGEROUS_LINKS, true))
        FactorCategory.BLOCKED_CALLS -> viewModel.onEvent(ScoreUiEvent.ToggleProtection(FactorCategory.BLOCKED_CALLS, true))
        else -> viewModel.onEvent(ScoreUiEvent.Recalculate)
    }
}
