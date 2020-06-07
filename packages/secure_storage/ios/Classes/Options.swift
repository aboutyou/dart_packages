import Flutter
import UIKit

func parseFlutterMethodQuery(args:[String: Any]) -> [CFString: Any] {
    var query: [CFString: Any] = [:];
    
    if let keychainClass = args["keychain-class"] as? [String: Any] {
        if let type = keychainClass["type"] as? String {
            switch (type) {
            case "generic-password":
                query[kSecClass] = kSecClassGenericPassword
                
                if let account = keychainClass["account"] as? String {
                    query[kSecAttrAccount] = account
                }
                
                if let service = keychainClass["service"] as? String {
                    query[kSecAttrService] = service
                }
            
                break;
            default:
                break;
            }
        }
    }
    
    return query;
}
