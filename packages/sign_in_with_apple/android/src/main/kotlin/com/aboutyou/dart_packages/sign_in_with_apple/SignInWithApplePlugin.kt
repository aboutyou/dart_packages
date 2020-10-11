package com.aboutyou.dart_packages.sign_in_with_apple

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.browser.customtabs.CustomTabsIntent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.Log

val TAG = "SignInWithApple"

/** SignInWithApplePlugin */
public class SignInWithApplePlugin: FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
  private val CUSTOM_TABS_REQUEST_CODE = 1001;

  private var channel: MethodChannel? = null

  private var binding: ActivityPluginBinding? = null

  private var activity: Activity? = null

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
    var lastAuthorizationRequestResult: Result? = null
    var triggerMainActivityToHideChromeCustomTab : (() -> Unit)? = null

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "com.aboutyou.dart_packages.sign_in_with_apple")
      val plugin = SignInWithApplePlugin()
      channel.setMethodCallHandler(plugin)

      registrar.addActivityResultListener(plugin)
      registrar.activity()?.let(plugin::registerActivity)

      val application = registrar.context().applicationContext as Application;

      application.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
        override fun onActivityPaused(activity: Activity) = Unit
        override fun onActivityResumed(activity: Activity) = Unit
        override fun onActivityDestroyed(activity: Activity?) = plugin.unregisterActivity()
        override fun onActivitySaveInstanceState(activity: Activity?, outState: Bundle?) = Unit
        override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) = plugin.registerActivity(activity)
        override fun onActivityStarted(activity: Activity) = Unit
        override fun onActivityStopped(activity: Activity) = Unit
      })
    }
  }

  fun registerActivity(currentActivity: Activity) {
    activity = currentActivity
  }

  fun unregisterActivity() {
    activity = null
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "isAvailable" -> result.success(true)
      "performAuthorizationRequest" -> performAuthorizationRequest(result, call)
      else -> result.notImplemented()
    }
  }

  private fun performAuthorizationRequest(result: Result, call: MethodCall) {
    val currentActivity = activity

    if (currentActivity == null) {
      result.error("MISSING_ACTIVITY", "Plugin is not attached to an activity", call.arguments)
      return
    }

    val url: String? = call.argument("url")

    if (url == null) {
      result.error("MISSING_ARG", "Missing 'url' argument", call.arguments)
      return
    }

    lastAuthorizationRequestResult?.error("NEW_REQUEST", "A new request came in while this was still pending. The previous request (this one) was then cancelled.", null)
    if (triggerMainActivityToHideChromeCustomTab != null) {
      triggerMainActivityToHideChromeCustomTab!!()
    }

    lastAuthorizationRequestResult = result
    triggerMainActivityToHideChromeCustomTab = {
      val notificationIntent = currentActivity.packageManager.getLaunchIntentForPackage(currentActivity.packageName);
      notificationIntent.setPackage(null)
      // Bring the Flutter activity back to the top, by popping the Chrome Custom Tab
      notificationIntent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP;
      currentActivity.startActivity(notificationIntent)
    }

    val builder = CustomTabsIntent.Builder();
    val customTabsIntent = builder.build();
    customTabsIntent.intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
    customTabsIntent.intent.data = Uri.parse(url)

    currentActivity.startActivityForResult(
            customTabsIntent.intent,
            CUSTOM_TABS_REQUEST_CODE,
            customTabsIntent.startAnimationBundle
    )
  }


  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    binding.addActivityResultListener(this)
    activity = binding.activity
    this.binding = binding;
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
    activity = null
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == CUSTOM_TABS_REQUEST_CODE) {
      val _lastAuthorizationRequestResult = lastAuthorizationRequestResult

      if (_lastAuthorizationRequestResult != null) {
        _lastAuthorizationRequestResult.error("authorization-error/canceled", "The user closed the Custom Tab", null)

        lastAuthorizationRequestResult = null
        triggerMainActivityToHideChromeCustomTab = null
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
public class SignInWithAppleCallback: Activity {
  constructor() : super()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // Note: The order is important here, as we first need to send the data to Flutter and then close the custom tab
    // That way we can detect a manually closed tab in `SignInWithApplePlugin.onActivityResult` (by detecting that we're still waiting on data)
    val lastAuthorizationRequestResult = SignInWithApplePlugin.lastAuthorizationRequestResult
    if (lastAuthorizationRequestResult != null) {
      lastAuthorizationRequestResult.success(intent?.data?.toString())
      SignInWithApplePlugin.lastAuthorizationRequestResult = null
    } else {
      SignInWithApplePlugin.triggerMainActivityToHideChromeCustomTab = null

      Log.e(TAG, "Received Sign in with Apple callback, but 'lastAuthorizationRequestResult' function was `null`")
    }

    val triggerMainActivityToHideChromeCustomTab = SignInWithApplePlugin.triggerMainActivityToHideChromeCustomTab
    if (triggerMainActivityToHideChromeCustomTab != null) {
      triggerMainActivityToHideChromeCustomTab()
      SignInWithApplePlugin.triggerMainActivityToHideChromeCustomTab = null
    } else {
      Log.e(TAG, "Received Sign in with Apple callback, but 'triggerMainActivityToHideChromeCustomTab' function was `null`")
    }

    finish()
  }
}
