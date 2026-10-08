plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.cyberguard.xai"
    compileSdk = 37
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.cyberguard.xai"
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    sourceSets {
        getByName("main") {
            assets.srcDir("${project.layout.buildDirectory.get()}/intermediates/flutter/assets_bundle_root")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

val prepareFlutterAssetsForMerge = tasks.register("prepareFlutterAssetsForMerge") {
    dependsOn(tasks.matching { it.name.startsWith("compileFlutterBuild") })
    val buildDir = project.layout.buildDirectory.get().asFile
    doLast {
        val rootDir = File(buildDir, "intermediates/flutter/assets_bundle_root/flutter_assets")
        rootDir.mkdirs()
        listOf("release", "debug").forEach { variant ->
            val srcDir = File(buildDir, "intermediates/flutter/$variant/flutter_assets")
            if (srcDir.exists()) {
                project.copy {
                    from(srcDir)
                    into(rootDir)
                }
            }
        }
    }
}

tasks.matching { it.name.startsWith("merge") && it.name.endsWith("Assets") }.configureEach {
    dependsOn(prepareFlutterAssetsForMerge)
    doLast {
        val variantName = if (name.contains("Release")) "release" else "debug"
        val buildDir = project.layout.buildDirectory.get().asFile
        val flutterAssetsDir = File(buildDir, "intermediates/flutter/$variantName/flutter_assets")
        val targetDir = File(buildDir, "intermediates/assets/$variantName/$name/flutter_assets")
        if (flutterAssetsDir.exists()) {
            project.copy {
                from(flutterAssetsDir)
                into(targetDir)
            }
        }
    }
}

