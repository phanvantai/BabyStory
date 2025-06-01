import Foundation

/// Service to provide app information from the main bundle
class AppInfoService {
  static let shared = AppInfoService()
  
  private init() {}
  
  /// Get the app name from the bundle
  var appName: String {
    Bundle.main.infoDictionary?["CFBundleName"] as? String ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "SoftDreams"
  }
  
  /// Get the app version from the bundle
  var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    return version
  }
  
  /// Get the build number from the bundle
  var buildNumber: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
  }
  
  /// Get formatted version string (version + build number)
  var versionWithBuild: String {
    "\(appVersion) (\(buildNumber))"
  }
}
