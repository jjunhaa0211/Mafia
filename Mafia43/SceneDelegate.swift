import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        game()
    }
    private func game() {
        window?.rootViewController = UINavigationController(rootViewController: MafiaViewController())
        window?.makeKeyAndVisible()
    }
}
