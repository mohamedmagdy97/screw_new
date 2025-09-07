pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false

//    id("com.google.android.gms:play-services-ads") version "22.6.0" apply false
}

include(":app")

//dependencies {
//    implementation 'com.google.android.gms:play-services-ads:22.6.0'
//    implementation 'com.android.support:multidex:2.0.1'
//    implementation "com.google.android.material:material:1.7.0"
//    implementation "androidx.browser:browser:1.4.0"
//
//}
