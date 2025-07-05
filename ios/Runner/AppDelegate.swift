import Flutter
import UIKit
import Firebase
import StoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    var Presult: FlutterResult?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Set up method channels
        if let controller = window?.rootViewController as? FlutterViewController {
            setupNativeChannel(controller: controller)
            setupBatteryChannel(controller: controller)
        }
        
        // Register plugins
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupNativeChannel(controller: FlutterViewController) {
        let nativeChannel = FlutterMethodChannel(
            name: "flutter.native/helper",
            binaryMessenger: controller.binaryMessenger
        )
        
        nativeChannel.setMethodCallHandler { [weak self] call, result in
            if call.method == "openInAppReview" {
                if #available(iOS 13.0, *) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        SKStoreReviewController.requestReviewInCurrentScene()
                    }
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func setupBatteryChannel(controller: FlutterViewController) {
        let batteryChannel = FlutterMethodChannel(
            name: "platform_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        batteryChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            self.Presult = result
            print("Method channel called")
            
            if call.method == "getReceiptData" {
                self.handleGetReceiptData()
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func handleGetReceiptData() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                // Retrieve receipt data
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                print("Receipt data retrieved successfully")
                
                // Encode receipt to Base64
                let receiptString = receiptData.base64EncodedString(options: [])
                print("Receipt String: \(receiptString)")
                
                // Return the receipt string as the result
                Presult?(receiptString)
            } catch {
                print("Error reading receipt data: \(error.localizedDescription)")
                Presult?("null")
            }
        } else {
            print("No receipt found at the expected URL")
            Presult?("null")
        }
    }
}

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                if #available(iOS 14.0, *) {
                    requestReview(in: scene)
                } else {
                    print("In-app review is not supported on this iOS version")
                }
            }
        }
    }
}
