package com.cyberguard.xai.core.network

import android.content.Context
import android.util.Log
import com.cyberguard.xai.BuildConfig
import com.cyberguard.xai.core.security.SecureStorage
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.http.ContentType
import io.ktor.http.contentType
import io.ktor.http.isSuccess
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
data class BackendSignalDto(
    val name: String,
    val category: String,
    val score_impact: Int = 0,
    val is_positive: Boolean = false,
    val description: String = ""
)

@Serializable
data class BackendAnalysisResult(
    val riskScore: Int,
    val severity: String,
    val decision: String,
    val signals: List<BackendSignalDto> = emptyList(),
    val evidence: List<String> = emptyList(),
    val recommendation: String,
    val confidence: Float
)

@Serializable
data class BackendAssistantMessage(
    val risk: String = "",
    val evidence: List<String> = emptyList(),
    val explanation: String = "",
    val recommended_action: String = "",
    val confidence: String = "",
    val is_certainty_claimed: Boolean = false
)

@Serializable
data class BackendAssistantResponse(
    val conversation_id: String,
    val question: String,
    val response: BackendAssistantMessage
)

/**
 * Android Client gateway for communicating securely with the CyberGuard FastAPI AI backend.
 * Endpoints:
 * - POST /analyze/url
 * - POST /analyze/message
 * - POST /analyze/phone
 * - POST /analyze/qr
 * - POST /analyze/deepfake
 * - POST /assistant/chat
 * - GET /health
 */
class CyberBackendClient(private val context: Context) {

    private val secureStorage = SecureStorage(context)
    private val baseUrl = BuildConfig.BACKEND_BASE_URL.trimEnd('/')

    private val httpClient = HttpClient(OkHttp) {
        install(ContentNegotiation) {
            json(Json {
                ignoreUnknownKeys = true
                isLenient = true
            })
        }
    }

    private fun getAuthToken(): String {
        return secureStorage.getAccessToken() ?: "demo_android_client_token"
    }

    suspend fun checkHealth(): Boolean {
        return try {
            val response = httpClient.get("$baseUrl/health")
            response.status.isSuccess()
        } catch (e: Exception) {
            Log.w(TAG, "Backend health check failed: ${e.message}")
            false
        }
    }

    suspend fun analyzeUrl(url: String): BackendAnalysisResult? {
        return try {
            val response = httpClient.post("$baseUrl/analyze/url") {
                contentType(ContentType.Application.Json)
                header("Authorization", "Bearer ${getAuthToken()}")
                setBody(mapOf("url" to url))
            }
            if (response.status.isSuccess()) response.body() else null
        } catch (e: Exception) {
            Log.e(TAG, "URL analysis failed: ${e.message}")
            null
        }
    }

    suspend fun analyzeMessage(message: String, sender: String = ""): BackendAnalysisResult? {
        return try {
            val response = httpClient.post("$baseUrl/analyze/message") {
                contentType(ContentType.Application.Json)
                header("Authorization", "Bearer ${getAuthToken()}")
                setBody(mapOf("message" to message, "sender" to sender))
            }
            if (response.status.isSuccess()) response.body() else null
        } catch (e: Exception) {
            Log.e(TAG, "Message analysis failed: ${e.message}")
            null
        }
    }

    suspend fun analyzePhone(phoneNumber: String, callerName: String = ""): BackendAnalysisResult? {
        return try {
            val response = httpClient.post("$baseUrl/analyze/phone") {
                contentType(ContentType.Application.Json)
                header("Authorization", "Bearer ${getAuthToken()}")
                setBody(mapOf("phone_number" to phoneNumber, "caller_name" to callerName))
            }
            if (response.status.isSuccess()) response.body() else null
        } catch (e: Exception) {
            Log.e(TAG, "Phone analysis failed: ${e.message}")
            null
        }
    }

    suspend fun analyzeQr(payload: String): BackendAnalysisResult? {
        return try {
            val response = httpClient.post("$baseUrl/analyze/qr") {
                contentType(ContentType.Application.Json)
                header("Authorization", "Bearer ${getAuthToken()}")
                setBody(mapOf("payload" to payload))
            }
            if (response.status.isSuccess()) response.body() else null
        } catch (e: Exception) {
            Log.e(TAG, "QR analysis failed: ${e.message}")
            null
        }
    }

    suspend fun analyzeDeepfake(mediaType: String, fileName: String): BackendAnalysisResult? {
        return try {
            val response = httpClient.post("$baseUrl/analyze/deepfake") {
                contentType(ContentType.Application.Json)
                header("Authorization", "Bearer ${getAuthToken()}")
                setBody(mapOf("media_type" to mediaType, "file_name" to fileName))
            }
            if (response.status.isSuccess()) response.body() else null
        } catch (e: Exception) {
            Log.e(TAG, "Deepfake analysis failed: ${e.message}")
            null
        }
    }

    companion object {
        private const val TAG = "CyberBackendClient"
    }
}
