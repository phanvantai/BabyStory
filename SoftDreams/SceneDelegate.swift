import SwiftUI

/// Scene Delegate that provides access to the AppViewModel for views that aren't in the SwiftUI view hierarchy
class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var appViewModel: AppViewModel?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // This method will be called when the app starts
    }
}

/// Extension to allow accessing SceneDelegate and the AppViewModel from views
extension UIApplication {
    static var appViewModel: AppViewModel? {
        return (shared.connectedScenes.first?.delegate as? SceneDelegate)?.appViewModel
    }
}
