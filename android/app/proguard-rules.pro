# Supabase & Ktor Proguard Rules
-keepattributes *Annotation*, InnerClasses, EnclosingMethod
-keepclassmembers class * {
    @kotlinx.serialization.Serializable <fields>;
}
-keepclassmembers class * {
    @kotlinx.serialization.SerialName <fields>;
}

# AndroidX Security Crypto
-keepclassmembers class androidx.security.crypto.** { *; }
