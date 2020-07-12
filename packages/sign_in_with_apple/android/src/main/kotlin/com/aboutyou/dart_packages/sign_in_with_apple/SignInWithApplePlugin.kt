package com.aboutyou.dart_packages.sign_in_with_apple

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.browser.customtabs.CustomTabsIntent
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.auth0.android.jwt.DecodeException
import com.auth0.android.jwt.JWT

val TAG = "SignInWithApple"

/**
 * A class representing an ongoing login attempt for Sign in with Apple.
 *
 * The [result] is the [Result] from the triggered [MethodCall].
 *
 * The [triggerMainActivityToHideChromeCustomTab] is a function which brings the actual app back to the foreground when the login attempt is finished.
 */
class OnGoingLoginAttempt(
  val result: Result,
  val triggerMainActivityToHideChromeCustomTab: () -> Unit,
  val nonce: String?
) {}

/** SignInWithApplePlugin */
public class SignInWithApplePlugin: FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
  private val CUSTOM_TABS_REQUEST_CODE = 1001;

  private var channel: MethodChannel? = null

  private var binding: ActivityPluginBinding? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.aboutyou.dart_packages.sign_in_with_apple")
    channel?.setMethodCallHandler(this);
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    channel = null
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    var onGoingLoginAttempt: OnGoingLoginAttempt? = null

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "com.aboutyou.dart_packages.sign_in_with_apple")
      channel.setMethodCallHandler(SignInWithApplePlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "isAvailable" -> result.success(true)
      "performAuthorizationRequest" -> {
        val activity = binding?.activity
        if (activity == null) {
          result.error("MISSING_ACTIVITY", "Plugin is not attached to an activity", call.arguments)
          return
        }

        val url: String? = call.argument("url")
        if (url == null) {
          result.error("MISSING_ARG", "Missing 'url' argument", call.arguments)
          return
        }

        val uri = Uri.parse(url)
        val onGoingLoginAttempt = onGoingLoginAttempt

        if (onGoingLoginAttempt != null) {
          onGoingLoginAttempt.result.error(
            "NEW_REQUEST",
            "A new request came in while this was still pending. The previous request (this one) was then cancelled.",
            null
          )
          onGoingLoginAttempt.triggerMainActivityToHideChromeCustomTab()
        }

        SignInWithApplePlugin.onGoingLoginAttempt = OnGoingLoginAttempt(
          result,
          {
            val notificationIntent = activity.packageManager.getLaunchIntentForPackage(activity.packageName);
            notificationIntent.setPackage(null)

            // Bring the Flutter activity back to the top, by popping the Chrome Custom Tab
            notificationIntent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP;

            activity.startActivity(notificationIntent)
          },
          uri.getQueryParameter("nonce")
        )

        val builder = CustomTabsIntent.Builder();
        val customTabsIntent = builder.build();
        customTabsIntent.intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
        customTabsIntent.intent.data = Uri.parse(url)

        activity.startActivityForResult(
          customTabsIntent.intent,
          CUSTOM_TABS_REQUEST_CODE,
          customTabsIntent.startAnimationBundle
        )
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.binding = binding
    binding.addActivityResultListener(this)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onDetachedFromActivity() {
    binding?.removeActivityResultListener(this)
    binding = null
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == CUSTOM_TABS_REQUEST_CODE) {
      val onGoingLoginAttempt = onGoingLoginAttempt

      if (onGoingLoginAttempt != null) {
        onGoingLoginAttempt.result.error("authorization-error/canceled", "The user closed the Custom Tab", null)

        SignInWithApplePlugin.onGoingLoginAttempt = null
      }
    }

    return false
  }
}

/**
 * Activity which is used when the web-based authentication flow links back to the app
 *
 * DO NOT rename this or it's package name as it's configured in the consumer's `AndroidManifest.xml`
 */
public class SignInWithAppleCallback : Activity() {
  private fun validateNonce( uri: Uri, expectedNonce: String?): Boolean {
    val idToken = uri.getQueryParameter("id_token")
    if (idToken == null) {
      Log.e(TAG, "Missing id_token query parameter in signinwithapple callback")
      return false
    }

    try {
      val jwt = JWT(idToken)

      if (jwt.getClaim("nonce_supported").asBoolean() == true) {
        if (jwt.getClaim("nonce").asString() != expectedNonce) {
          Log.e(TAG, "Expected that the JWT nonce matches the initially provided one, but they differed")
          return false
        }
      }

      return true
    } catch ( exception: DecodeException) {
      Log.e(TAG, "Error while decoding JWT id_token from uri")
      return false
    }
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val onGoingLoginAttempt = SignInWithApplePlugin.onGoingLoginAttempt
    if (onGoingLoginAttempt == null) {
      Log.e(TAG, "Received Sign in with Apple callback, but 'onGoingRequest' doesn't exist")
      finish()
      return
    }

    val uri = intent?.data
    if (uri == null) {
      Log.e(TAG, "Received Sign in with Apple callback, but no uri was provided on the intent")
      finish()
      return
    }

    if (!validateNonce(uri, onGoingLoginAttempt.nonce)) {
      Log.e(TAG, "Received Sign in with Apple callback, but the nonce parameter validation failed")
      finish()
      return
    }

    // Note: The order is important here, as we first need to send the data to Flutter and then close the custom tab
    // That way we can detect a manually closed tab in `SignInWithApplePlugin.onActivityResult` (by detecting that we're still waiting on data)
    onGoingLoginAttempt.result.success(uri.toString())
    onGoingLoginAttempt.triggerMainActivityToHideChromeCustomTab()

    SignInWithApplePlugin.onGoingLoginAttempt = null

    finish()
  }
}
