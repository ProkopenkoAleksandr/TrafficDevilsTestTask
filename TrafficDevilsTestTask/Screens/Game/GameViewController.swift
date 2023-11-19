//
//  GameViewController.swift
//  TrafficDevilsTestTask
//
//  Created by Prokopenko Aleksandr on 17.11.2023.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    private var customView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground

        customView = SKView(frame: self.view.frame)
        
        if customView != nil {
            self.view.addSubview(customView!)
            let scene = MainScene(size: (view?.bounds.size)!)
            scene.scaleMode = .aspectFill

            customView?.presentScene(scene)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showWebView), name: NSNotification.Name("EndGame"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        (customView?.scene as? MainScene)?.isPaused = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        (customView?.scene as? MainScene)?.startGame()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("EndGame"), object: nil)
    }
    
    @objc private func showWebView(_ notification: Notification) {
        if let userInfo = notification.userInfo, let winner = userInfo["winner"] as? Bool {
            if winner == true, let winnerString = UserDefaults.standard.string(forKey: "winner") {
                presentWebViewVC(urlString: winnerString)
            } else if winner == false, let loserString = UserDefaults.standard.string(forKey: "loser") {
                presentWebViewVC(urlString: loserString)
            } else {
                (customView?.scene as? MainScene)?.startGame()
            }
        }
    }
    
    private func presentWebViewVC(urlString: String) {
        let webViewVC = WebViewViewController(urlString: urlString)
        let navCon = UINavigationController(rootViewController: webViewVC)
        navCon.modalPresentationStyle = .fullScreen
        navCon.navigationBar.backgroundColor = .systemBackground
        present(navCon, animated: true, completion: nil)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
