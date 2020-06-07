import Flutter
import UIKit

@available(iOS 11.3, *)
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
    print(call.method)
    print(call.arguments)
    // Makes sure arguments exists and is a List
    guard let args = call.arguments as? [String: Any] else {
        // TODO: Call result with proper error
        return
    }
    
    switch call.method {
    case "read":
        var query = parseFlutterMethodQuery(args: args)
        query[kSecReturnData] = true
        
        var item: CFTypeRef?;
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if let data = item as? Data {
            result(String(data: data, encoding: String.Encoding.utf8))
        }
        
        // TODO: Otherwise error
        
        break;
    case "write":
       var query = parseFlutterMethodQuery(args: args)
       
       query[kSecValueData] = (args["value"] as! String).data(using: String.Encoding.utf8)
       
       let status = SecItemAdd(query as CFDictionary, nil)
       
       if status == errSecDuplicateItem {
        let attr = [
            kSecValueData: (args["value"] as! String).data(using: String.Encoding.utf8)
        ]
            
        SecItemUpdate(query as CFDictionary, attr as CFDictionary)
       }
       
       result("");
        
        break;
        
    case "delete":
        break;
        
        
    default:
        result(FlutterMethodNotImplemented)
        break;
    }
  }
}
