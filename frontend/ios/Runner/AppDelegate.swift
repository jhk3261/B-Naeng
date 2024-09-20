import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Google Maps API 키 초기화
    GMSServices.provideAPIKey("AIzaSyAzFqc4cSwpIZRycZ3qHKrPK8ybOiPVhJ8") // 여기에 실제 API 키를 입력하세요.
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
