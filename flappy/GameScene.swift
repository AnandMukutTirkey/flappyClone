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
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        scoreLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + self.frame.height/3)
        scoreLabel.zPosition = 4
        self.addChild(scoreLabel)
        ground = SKSpriteNode(imageNamed: "ground")
        ground.setScale(0.5)
        ground.position = CGPoint(x: self.frame.width/2, y: ground.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.categoryBitMask = physicsCategory.ground
        ground.physicsBody?.collisionBitMask = physicsCategory.bird
        ground.physicsBody?.contactTestBitMask = physicsCategory.bird
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.dynamic = false
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
        bird.physicsBody?.dynamic = true
        bird.zPosition = 2
        
        self.addChild(bird)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if gameStarted == false{
            gameStarted = true
            bird.physicsBody?.affectedByGravity = true
            let spawn = SKAction.runBlock({
                () in
                self.createWalls()
            })
            let delay = SKAction.waitForDuration(2.0)
            let spawnDelay = SKAction.sequence([spawn,delay])
            let spawnDelayForever = SKAction.repeatActionForever(spawnDelay)
            self.runAction(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + 20)
            let movePipes = SKAction.moveByX(-distance, y: 0, duration: 0.01 * Double(distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes,removePipes])
            
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 35))
        }else{
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 35))
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
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
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.categoryBitMask = physicsCategory.scoreNode
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = physicsCategory.bird
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        //scoreNode.color = SKColor.blueColor()

        topWall.position = CGPoint(x: self.frame.width, y: self.frame.height/2 + 350)
        bottomWall.position = CGPoint(x: self.frame.width, y: self.frame.height/2 - 350)
        topWall.setScale(0.5)
        bottomWall.setScale(-0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = physicsCategory.wall
        topWall.physicsBody?.collisionBitMask = physicsCategory.bird
        topWall.physicsBody?.contactTestBitMask = physicsCategory.bird
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOfSize: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = physicsCategory.wall
        bottomWall.physicsBody?.collisionBitMask = physicsCategory.bird
        bottomWall.physicsBody?.contactTestBitMask = physicsCategory.bird
        bottomWall.physicsBody?.dynamic = false
        bottomWall.physicsBody?.affectedByGravity = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        wallPair.addChild(scoreNode)
        wallPair.zPosition = 1
        
        let randomY = CGFloat(Float(arc4random()) / 0xFFFFFFFF) * CGFloat(max - min ) + CGFloat(min)
        wallPair.position.y = wallPair.position.y + randomY
        wallPair.runAction(moveAndRemove)
        self.addChild(wallPair)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
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
