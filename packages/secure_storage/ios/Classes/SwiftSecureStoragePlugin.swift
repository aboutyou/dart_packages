import Flutter
import UIKit

public class SwiftSecureStoragePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
        name: "com.aboutyou.dart_packages.secure_storage",
        binaryMessenger: registrar.messenger()
    )
    let instance = SwiftSecureStoragePlugin()
    
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Makes sure arguments exists and is a List
    guard let args = call.arguments as? [String: Any] else {
        // TODO: Call result with proper error
        return
    }
    
    // Every request will need a key
    guard let key = args["key"] as? String else {
        // TODO: Call result with proper error
        return
    }
    
    switch call.method {
    case "read":
        let attributes: [String: Any] = [
            kSecClass as String: "",
        ];
        
        var result: CFTypeRef?;
        
        let status = SecItemCopyMatching(attributes as CFDictionary, &result)
        
        if (status == noErr) {
            // TODO: Parse result
        }
        
        
        break;
    case "write":
       
        
        guard let value = args["value"] as? String else {
            // TODO: Call result with proper error
            return
        }
        
        
        let attributes = [
            kSecClass: "",
            kSecValueData: value,
        ] as CFDictionary;
        
        SecItemAdd(attributes, nil);
        
        break;
        
    case "delete":
        break;
        
        
    default:
        result(FlutterMethodNotImplemented)
        break;
    }
  }
}
