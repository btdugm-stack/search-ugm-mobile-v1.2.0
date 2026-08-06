import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "id.ac.ugm.search_ugm_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_17.toString() }
    defaultConfig {
        applicationId = "id.ac.ugm.search"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    buildTypes { release { signingConfig = signingConfigs.getByName("debug") } }
}

// Nama file APK: Search-UGM-<versionName>-<timestamp>.apk (mis. Search-UGM-1.2.0-20260806-1334.apk)
android {
    applicationVariants.all {
        outputs.all {
            val ts = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmm"))
            (this as com.android.build.gradle.internal.api.BaseVariantOutputImpl).outputFileName =
                "Search-UGM-${versionName}-${ts}.apk"
        }
    }
}

flutter { source = "../.." }
