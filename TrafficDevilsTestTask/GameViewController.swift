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
        
        customView = SKView(frame: self.view.frame)
        
        if customView != nil {
            self.view.addSubview(customView!)
            let scene = MainScene(size: (view?.bounds.size)!)
            scene.scaleMode = .aspectFill

            customView?.presentScene(scene)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
