package com.cyberguard.xai.domain.model

data class User(
    val id: String,
    val email: String,
    val fullName: String? = null,
    val securityScore: Int = 85,
    val isProtectionActive: Boolean = true
)
