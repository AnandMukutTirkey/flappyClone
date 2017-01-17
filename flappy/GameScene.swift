//
//  GameScene.swift
//  flappy
//
//  Created by anand mukut tirkey on 22/09/16.
//  Copyright (c) 2016 anand mukut tirkey. All rights reserved.
//

import SpriteKit

struct physicsCategory {
    static let bird : UInt32 = 0x1 << 1
    static let ground : UInt32 = 0x1 << 2
    static let wall : UInt32 = 0x1 << 3
    static let scoreNode : UInt32 = 0x1 << 4

}

class GameScene: SKScene , SKPhysicsContactDelegate {
    var score = 0
    let scoreLabel = SKLabelNode()
    var ground = SKSpriteNode()
    var bird = SKSpriteNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        scoreLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + self.frame.height/3)
        scoreLabel.zPosition = 4
        self.addChild(scoreLabel)
        ground = SKSpriteNode(imageNamed: "ground")
        ground.setScale(0.5)
        ground.position = CGPoint(x: self.frame.width/2, y: ground.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = physicsCategory.ground
        ground.physicsBody?.collisionBitMask = physicsCategory.bird
        ground.physicsBody?.contactTestBitMask = physicsCategory.bird
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        ground.zPosition = 3
        self.addChild(ground)
        
        bird = SKSpriteNode(imageNamed: "mybird")
        bird.size = CGSize(width: 60, height: 60)
        bird.position = CGPoint(x: self.frame.width/2 - bird.frame.width, y: self.frame.height/2)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: (bird.frame.height/2 - 10) )
        bird.physicsBody?.categoryBitMask = physicsCategory.bird
        bird.physicsBody?.collisionBitMask = physicsCategory.ground | physicsCategory.wall
        bird.physicsBody?.contactTestBitMask = physicsCategory.scoreNode | physicsCategory.ground | physicsCategory.wall
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        bird.zPosition = 2
        
        self.addChild(bird)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        if gameStarted == false{
            gameStarted = true
            bird.physicsBody?.affectedByGravity = true
            let spawn = SKAction.run({
                () in
                self.createWalls()
            })
            let delay = SKAction.wait(forDuration: 2.0)
            let spawnDelay = SKAction.sequence([spawn,delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + 20)
            let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: 0.01 * Double(distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes,removePipes])
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 35))
        }else{
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 35))
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func createWalls (){
        let wallPair = SKNode()
        let (min,max) = (-200.0,200.0)
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Wall")
        
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 1,height: 200)
        scoreNode.position = CGPoint(x: self.frame.width ,y: self.frame.height/2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.categoryBitMask = physicsCategory.scoreNode
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = physicsCategory.bird
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        //scoreNode.color = SKColor.blueColor()

        topWall.position = CGPoint(x: self.frame.width, y: self.frame.height/2 + 350)
        bottomWall.position = CGPoint(x: self.frame.width, y: self.frame.height/2 - 350)
        topWall.setScale(0.5)
        bottomWall.setScale(-0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = physicsCategory.wall
        topWall.physicsBody?.collisionBitMask = physicsCategory.bird
        topWall.physicsBody?.contactTestBitMask = physicsCategory.bird
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = physicsCategory.wall
        bottomWall.physicsBody?.collisionBitMask = physicsCategory.bird
        bottomWall.physicsBody?.contactTestBitMask = physicsCategory.bird
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.physicsBody?.affectedByGravity = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        wallPair.addChild(scoreNode)
        wallPair.zPosition = 1
        
        let randomY = CGFloat(Float(arc4random()) / 0xFFFFFFFF) * CGFloat(max - min ) + CGFloat(min)
        wallPair.position.y = wallPair.position.y + randomY
        wallPair.run(moveAndRemove)
        self.addChild(wallPair)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        if (firstBody.categoryBitMask == physicsCategory.bird && secondBody.categoryBitMask == physicsCategory.scoreNode) || (firstBody.categoryBitMask == physicsCategory.scoreNode && secondBody.categoryBitMask == physicsCategory.bird){
            score += 1
            print(score)
            scoreLabel.text = String(score)
        }else{
            print("restart")
            score -= 1
            scoreLabel.text = String(score)
        }
    }
}
