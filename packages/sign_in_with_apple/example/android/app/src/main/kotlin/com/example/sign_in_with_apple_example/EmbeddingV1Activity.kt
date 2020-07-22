package com.example.sign_in_with_apple_example

import com.aboutyou.dart_packages.sign_in_with_apple.SignInWithApplePlugin
import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;

class EmbeddingV1Activity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        SignInWithApplePlugin.registerWith(registrarFor("com.aboutyou.dart_packages.sign_in_with_apple"));
        E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
    }
}
