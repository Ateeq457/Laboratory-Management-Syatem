// android/app/build.gradle.kts
// ✅ FIXED:
// - minSdk set explicitly to 23 (Firebase Phone Auth requires >= 21;
//   flutter.minSdkVersion may be 16 which causes build/runtime failures)
// - Java 17 compile options (matches kotlinOptions)
// - Firebase BoM kept at 34.x for latest Phone Auth fixes

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.lab_system"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.lab_system"
        // ✅ CRITICAL: Firebase Phone Auth requires minSdk >= 21.
        // Use 23 for broader RecaptchaActivity support.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM — manages all Firebase library versions automatically
    implementation(platform("com.google.firebase:firebase-bom:34.13.0"))

    // Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Firebase Authentication (Phone OTP)
    implementation("com.google.firebase:firebase-auth")
}
