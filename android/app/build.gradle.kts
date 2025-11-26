plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.keneya_muso"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.keneya_muso"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
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

// Tâche pour copier l'APK au bon endroit pour Flutter
afterEvaluate {
    tasks.named("assembleDebug") {
        doLast {
            val apkFile = file("build/outputs/apk/debug/app-debug.apk")
            val targetDir = file("../../build/app/outputs/flutter-apk")
            if (apkFile.exists()) {
                targetDir.mkdirs()
                apkFile.copyTo(targetDir.resolve("app-debug.apk"), overwrite = true)
                println("APK copié vers: ${targetDir.resolve("app-debug.apk")}")
            }
        }
    }
}
