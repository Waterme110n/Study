plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "com.example.lab2"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.lab2"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            isTestCoverageEnabled = true // Включаем покрытие тестами
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    testOptions {
        unitTests.all {
            // Установите использование JUnit Platform
            it.useJUnitPlatform()
        }
    }
}

dependencies {
    testImplementation(libs.core)
    androidTestImplementation(libs.ext.junit)
    androidTestImplementation(libs.espresso.core)
    androidTestImplementation(libs.junit)
    testImplementation(libs.junit)
    androidTestImplementation(libs.mockito.android)
    androidTestImplementation(libs.core.testing.v210)
    testImplementation(libs.mockito.core)
    annotationProcessor(libs.compiler)
    implementation(libs.glide)
    implementation(libs.appcompat)
    implementation(libs.core.ktx)
    implementation(libs.room.runtime)
    implementation(libs.lifecycle.viewmodel)
    implementation(libs.lifecycle.livedata)
    implementation(libs.recyclerview)
    implementation(libs.databinding.runtime)
    implementation(libs.appcompat)
    implementation(libs.material)
    implementation(libs.activity)
    implementation(libs.constraintlayout)
}
