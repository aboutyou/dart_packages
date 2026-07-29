package com.aboutyou.dart_packages.sign_in_with_apple

import android.app.Activity
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
import io.flutter.Log
import java.util.concurrent.atomic.AtomicReference

val TAG = "SignInWithApple"

/** SignInWithApplePlugin */
public class SignInWithApplePlugin: FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
  private val CUSTOM_TABS_REQUEST_CODE = 1001;

  private var channel: MethodChannel? = null

  var binding: ActivityPluginBinding? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.aboutyou.dart_packages.sign_in_with_apple")
    channel?.setMethodCallHandler(this);
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    channel = null
  }

  companion object {
    private val pendingAuthorizationRequest: AtomicReference<Result?> = AtomicReference(null)

    var triggerMainActivityToHideChromeCustomTab : (() -> Unit)? = null

    internal fun setPendingAuthorizationRequest(result: Result) {
      pendingAuthorizationRequest.set(result)
    }

    /**
     * Completes the pending authorization request (if any) exactly once, returning whether there
     * was one to complete.
     *
     * All completion paths (the success deeplink in [SignInWithAppleCallback], the Custom Tab
     * being closed in [SignInWithApplePlugin.onActivityResult], and a new request superseding a
     * pending one) must funnel through here: the result is taken out of the shared slot *before*
     * replying, since a reply can throw after the message is already marked as replied (e.g. when
     * the engine is torn down mid-flow). If the slot were cleared only after a successful reply,
     * the next callback would reply a second time and crash with "Reply already submitted" (#458).
     */
    internal fun completePendingAuthorizationRequest(complete: (Result) -> Unit): Boolean {
      val result = pendingAuthorizationRequest.getAndSet(null) ?: return false

      try {
        complete(result)
      } catch (e: Exception) {
        Log.e(TAG, "Completing the pending authorization request failed", e)
      }

      return true
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "isAvailable" -> result.success(true)
      "performAuthorizationRequest" -> {
        val _activity = binding?.activity

        if (_activity == null) {
          result.error("MISSING_ACTIVITY", "Plugin is not attached to an activity", call.arguments)
          return
        }

        val url: String? = call.argument("url")

        if (url == null) {
          result.error("MISSING_ARG", "Missing 'url' argument", call.arguments)
          return
        }

        completePendingAuthorizationRequest {
          it.error("NEW_REQUEST", "A new request came in while this was still pending. The previous request (this one) was then cancelled.", null)
        }
        if (triggerMainActivityToHideChromeCustomTab != null) {
          triggerMainActivityToHideChromeCustomTab!!()
        }

        setPendingAuthorizationRequest(result)
        triggerMainActivityToHideChromeCustomTab = {
          val notificationIntent = _activity.packageManager.getLaunchIntentForPackage(_activity.packageName);
          notificationIntent?.setPackage(null)
          // Bring the Flutter activity back to the top, by popping the Chrome Custom Tab
          notificationIntent?.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP;
          _activity.startActivity(notificationIntent)
        }

        val builder = CustomTabsIntent.Builder();
        val customTabsIntent = builder.build();
        customTabsIntent.intent.data = Uri.parse(url)

        _activity.startActivityForResult(
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
      val completed = completePendingAuthorizationRequest {
        it.error("authorization-error/canceled", "The user closed the Custom Tab", null)
      }

      if (completed) {
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
    val completed = SignInWithApplePlugin.completePendingAuthorizationRequest {
      it.success(intent?.data?.toString())
    }
    if (!completed) {
      SignInWithApplePlugin.triggerMainActivityToHideChromeCustomTab = null

      Log.e(TAG, "Received Sign in with Apple callback, but no authorization request was pending")
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
