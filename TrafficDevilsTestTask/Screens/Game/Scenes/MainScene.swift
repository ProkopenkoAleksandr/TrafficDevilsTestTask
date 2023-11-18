//
//  MainScene.swift
//  TrafficDevilsTestTask
//
//  Created by Prokopenko Aleksandr on 17.11.2023.
//

import UIKit
import SpriteKit
import CoreMotion

class MainScene: SKScene {
    
    private var motionManager = CMMotionManager()
    private var gameTimer: Timer?
    private var gameSpentTime: Int = 0
    private var timer: Timer?

    private let ballCategory: UInt32 = 0x1 << 0
    private let obstacleCategory: UInt32 = 0x1 << 1
    private let wallCategory: UInt32 = 0x1 << 2
    private let ballFallSpeed: CGFloat = 1000.0
    
    private var holeWidth: CGFloat = 50
    private var triangleSize: CGFloat = 40
    
    private var startButton: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "orangeButton")
        node.size = CGSize(width: UIScreen.main.bounds.width - 40, height: 50)
        node.name = "playButton"
        
        let text = SKLabelNode(text: "Start the game")
        text.name = "playButtonText"
        text.fontSize = 32
        text.fontColor = .black
        text.position = CGPoint(x: 0, y: 0)
        text.horizontalAlignmentMode = .center
        text.verticalAlignmentMode = .center
        node.addChild(text)
        
        return node
    }()
    
    private var ball: SKShapeNode = {
        let node = SKShapeNode(circleOfRadius: 20)
        node.name = "ball"
        node.fillColor = .orange
        node.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        node.physicsBody?.restitution = 0.0
        node.physicsBody?.linearDamping = 0.0
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = 0x1 << 0
        node.physicsBody?.contactTestBitMask = 0x1 << 1
        
        return node
    }()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: -ballFallSpeed)
        startButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        createWalls()
        setupAccelerometer()
    }
    
    private func createWalls() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.restitution = 0.0
        physicsBody?.categoryBitMask = wallCategory
        physicsBody?.collisionBitMask = ballCategory
    }
    
    private func setupAccelerometer() {
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            if let acceleration = data?.acceleration {
                self?.updateBallVelocity(acceleration: acceleration)
            }
        }
    }

    private func updateBallVelocity(acceleration: CMAcceleration) {
        let sensitivity: CGFloat = 500.0
        ball.physicsBody?.velocity.dx = CGFloat(acceleration.x) * sensitivity
    }
    
    private func startStripGeneratorTimer() {
        generateStripWithHole()
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(generateStripWithHole), userInfo: nil, repeats: true)
    }

    @objc private func generateStripWithHole() {
        var moveRight = true
        let stripHeight: CGFloat = 5.0
        let stripWidth: CGFloat = size.width
        let holePosition = CGFloat.random(in: holeWidth / 2...(stripWidth - holeWidth / 2))
        let wallMoveSpeedCoefficient: CGFloat = 1.0 / 25.0

        let leftStrip = SKSpriteNode(color: .white, size: CGSize(width: holePosition - holeWidth / 2, height: stripHeight))
        leftStrip.name = "strip"
        leftStrip.position = CGPoint(x: leftStrip.size.width / 2, y: -stripHeight / 2)
        setupStrip(strip: leftStrip)
        addChild(leftStrip)

        let rightStrip = SKSpriteNode(color: .white, size: CGSize(width: stripWidth - (holePosition + holeWidth / 2), height: stripHeight))
        rightStrip.name = "strip"
        rightStrip.position = CGPoint(x: size.width - rightStrip.size.width / 2, y: -stripHeight / 2)
        setupStrip(strip: rightStrip)
        addChild(rightStrip)

        let moveLeftAction = SKAction.move(by: CGVector(dx: 0, dy: size.height + stripHeight), duration: TimeInterval(size.height / (ballFallSpeed * wallMoveSpeedCoefficient)))
        let removeAction = SKAction.removeFromParent()
        leftStrip.run(SKAction.sequence([moveLeftAction, removeAction]))
        
        let moveRightAction = SKAction.move(by: CGVector(dx: 0, dy: size.height + stripHeight), duration: TimeInterval(size.height / (ballFallSpeed * wallMoveSpeedCoefficient)))
        rightStrip.run(SKAction.sequence([moveRightAction, removeAction]))
        
        let stripsMovementTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(0.001), repeats: true) { timer in
            if moveRight == true {
                leftStrip.size.width += 0.1
                rightStrip.size.width -= 0.1
                
                leftStrip.position.x = leftStrip.size.width / 2
                rightStrip.position.x = self.size.width - rightStrip.size.width / 2
                
                setupStrip(strip: leftStrip)
                setupStrip(strip: rightStrip)
                
                if rightStrip.size.width <= 0 {
                    moveRight = false
                }
            } else {
                leftStrip.size.width -= 0.1
                rightStrip.size.width += 0.1
                
                leftStrip.position.x = leftStrip.size.width / 2
                rightStrip.position.x = self.size.width - rightStrip.size.width / 2
                
                setupStrip(strip: leftStrip)
                setupStrip(strip: rightStrip)
                
                if leftStrip.size.width <= 0 {
                    moveRight = true
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(size.height / (ballFallSpeed * wallMoveSpeedCoefficient)), repeats: false) { timer in
            stripsMovementTimer.invalidate()
        }
        
        func setupStrip(strip: SKSpriteNode) {
            strip.physicsBody = SKPhysicsBody(rectangleOf: strip.size)
            strip.physicsBody?.categoryBitMask = self.obstacleCategory
            strip.physicsBody?.contactTestBitMask = self.ballCategory
            strip.physicsBody?.collisionBitMask = 0
            strip.physicsBody?.affectedByGravity = false
            strip.physicsBody?.allowsRotation = false
        }
        
    }
    
    private func createTriangels() {
        let screenWidth = size.width
        let screenHeight = size.height
        
        let numberOfTriangles = Int(screenWidth / triangleSize)
        
        let distanceBetweenTriangles = screenWidth / CGFloat(numberOfTriangles)
        
        for i in 0..<numberOfTriangles {
            let triangle = TriangleShapeNode(size: triangleSize)
            triangle.name = "triangle"
            
            let xPosition = CGFloat(i) * distanceBetweenTriangles + distanceBetweenTriangles / 2
            let yPosition = screenHeight - triangle.frame.size.height / 2 - (view?.safeAreaInsets.top ?? 0)
            
            triangle.position = CGPoint(x: xPosition, y: yPosition)
            
            addChild(triangle)
        }
    }

    deinit {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func startGameTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.gameSpentTime += 1
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            if node.name == "playButton" || node.name == "playButtonText" {
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let scaleDown = SKAction.scale(to: 0.1, duration: 0.5)
                let groupAction = SKAction.group([fadeOut, scaleDown])

                self.isPaused = false
                createTriangels()
                startStripGeneratorTimer()
                startGameTimer()
                startButton.run(groupAction) {
                    self.startButton.removeFromParent()
                }
            }
        }
    }
    
    private func endGame() {
        removeAllChildren()
        removeAllActions()
        self.isPaused = true
        timer?.invalidate()
        timer = nil
        gameTimer?.invalidate()
        gameTimer = nil
        if gameSpentTime >= 30 {
            NotificationCenter.default.post(name: NSNotification.Name("EndGame"), object: nil, userInfo: ["winner": true])
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("EndGame"), object: nil, userInfo: ["winner": false])
        }
    }
    
    func startGame() {
        self.isPaused = true
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        self.startButton.alpha = 1.0
        self.startButton.xScale = 1.0
        self.startButton.yScale = 1.0
        addChild(ball)
        addChild(startButton)
    }
}

extension MainScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "strip" && contact.bodyB.node?.name == "triangle" {
            contact.bodyA.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "strip" && contact.bodyA.node?.name == "triangle" {
            contact.bodyB.node?.removeFromParent()
        }
        
        if contact.bodyA.node?.name == "ball" && contact.bodyB.node?.name == "triangle" {
            endGame()
        } else if contact.bodyB.node?.name == "ball" && contact.bodyA.node?.name == "triangle" {
            endGame()
        }
    }
}
