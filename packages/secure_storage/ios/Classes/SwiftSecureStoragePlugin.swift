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
    
    switch call.method {
    case "read":
        let query = parseFlutterMethodQuery(args: args)
        
        var r: CFTypeRef?;
        let status = SecItemCopyMatching(query, &r)
        
        if let data = r as? Data {
            result(String(data: data, encoding: String.Encoding.utf8))
        }
        
        // TODO: Otherwise error
        
        break;
    case "write":
       // TODO
        
        break;
        
    case "delete":
        break;
        
        
    default:
        result(FlutterMethodNotImplemented)
        break;
    }
  }
}
