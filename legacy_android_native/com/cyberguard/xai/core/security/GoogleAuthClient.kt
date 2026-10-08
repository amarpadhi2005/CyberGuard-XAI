package com.cyberguard.xai.core.security

import android.content.Context
import androidx.credentials.CredentialManager
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetCredentialResponse
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import com.cyberguard.xai.BuildConfig
import com.cyberguard.xai.core.util.Resource
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import java.security.MessageDigest
import java.util.UUID

class GoogleAuthClient(private val context: Context) {

    private val credentialManager = CredentialManager.create(context)

    suspend fun signInWithGoogle(): Resource<String> {
        val webClientId = BuildConfig.GOOGLE_WEB_CLIENT_ID
        if (webClientId.contains("YOUR_GOOGLE_CLIENT_ID")) {
            // Simulated token for development/hackathon demo when Google Cloud OAuth isn't provisioned
            return Resource.Success("mock_google_id_token_${UUID.randomUUID()}")
        }

        return try {
            val rawNonce = UUID.randomUUID().toString()
            val md = MessageDigest.getInstance("SHA-256")
            val digest = md.digest(rawNonce.toByteArray())
            val hashedNonce = digest.fold("") { str, it -> str + "%02x".format(it) }

            val googleIdOption = GetGoogleIdOption.Builder()
                .setFilterByAuthorizedAccounts(false)
                .setServerClientId(webClientId)
                .setAutoSelectEnabled(false)
                .setNonce(hashedNonce)
                .build()

            val request = GetCredentialRequest.Builder()
                .addCredentialOption(googleIdOption)
                .build()

            val response: GetCredentialResponse = credentialManager.getCredential(
                request = request,
                context = context
            )

            handleSignInResponse(response)
        } catch (e: GetCredentialCancellationException) {
            Resource.Error("Google sign-in was cancelled by user")
        } catch (e: GetCredentialException) {
            Resource.Error("Google sign-in error: ${e.localizedMessage ?: "Unknown error"}", e)
        } catch (e: Exception) {
            Resource.Error("Authentication error: ${e.localizedMessage}", e)
        }
    }

    private fun handleSignInResponse(response: GetCredentialResponse): Resource<String> {
        val credential = response.credential
        return when {
            credential is CustomCredential && credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL -> {
                try {
                    val googleIdTokenCredential = GoogleIdTokenCredential.createFrom(credential.data)
                    Resource.Success(googleIdTokenCredential.idToken)
                } catch (e: Exception) {
                    Resource.Error("Failed to parse Google ID token: ${e.message}")
                }
            }
            else -> {
                Resource.Error("Unexpected credential type received")
            }
        }
    }
}
