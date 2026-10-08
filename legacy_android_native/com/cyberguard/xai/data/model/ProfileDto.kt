package com.cyberguard.xai.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ProfileDto(
    @SerialName("id") val id: String,
    @SerialName("email") val email: String,
    @SerialName("full_name") val fullName: String? = null,
    @SerialName("phone_number") val phoneNumber: String? = null,
    @SerialName("security_score") val securityScore: Int = 85,
    @SerialName("protection_active") val protectionActive: Boolean = true,
    @SerialName("created_at") val createdAt: String? = null
)
