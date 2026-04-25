// File: android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter plugin
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase Google Services plugin (for google-services.json)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.finalpg"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Java 17 as in your snippet
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Your app id – must match what you registered in Firebase
        applicationId = "com.example.finalpg"

        // Flutter-managed versions
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Use debug signing for now so flutter run --release works
            signingConfig = signingConfigs.getByName("debug")

            // Optional, but recommended for smaller APKs
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            // keep default debug config
        }
    }

    // Optional: if you hit multidex or 64K method issues later
    // buildFeatures { viewBinding = true }
}

flutter {
    source = "../.."
}

// No extra dependencies here; Dart/Flutter uses Firebase via pubspec packages.
// Just ensure:
// - google-services.json is in android/app/
// - android/build.gradle has the google-services classpath.
