plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.smart_attendance_system"
    compileSdk = flutter.compileSdkVersion
    // Removed 'ndkVersion = flutter.ndkVersion' to explicitly set the required version
    ndkVersion = "27.0.12077973" // Keep this specific NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true // This is correctly enabled
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.smart_attendance_system"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        
        // --- මෙන්න මෙතන තමයි වෙනස කරේ ---
        minSdk = 23 
        // ------------------------------------
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add any existing dependencies here that were in your original file.
    // For example:
    // implementation(kotlin("stdlib-jdk8"))
    // implementation("androidx.core:core-ktx:1.9.0")

    // THIS IS THE CRUCIAL LINE FOR CORE LIBRARY DESUGARING
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}