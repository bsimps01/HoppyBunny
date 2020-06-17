//
//  GameScene.swift
//  HoppyBunny
//
//  Created by Benjamin Simpson on 6/12/20.
//  Copyright © 2020 Benjamin Simpson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var hero: SKSpriteNode!
    var scrollLayer: SKNode!
    var sinceTouch : CFTimeInterval = 0
    var obstacleSource: SKNode!
    var obstacleLayer: SKNode!
    var spawnTimer: CFTimeInterval = 0
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        /* Recursive node search for 'hero' (child of referenced node) */
        hero = (self.childNode(withName: "//hero") as! SKSpriteNode)

        /* allows the hero to animate when it's in the GameScene */
        hero.isPaused = false
        
        /* Set reference to scroll layer node */
        scrollLayer = self.childNode(withName: "scrollLayer")
        
        /* Set reference to obstacle Source node */
        obstacleSource = self.childNode(withName: "obstacle")
        
        /* Set reference to obstacle layer node */
        obstacleLayer = self.childNode(withName: "obstacleLayer")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        /* Apply vertical impulse */
        hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
        
        /* Apply subtle rotation */
        hero.physicsBody?.applyAngularImpulse(1)

        /* Reset touch timer */
        sinceTouch = 0
    }
    
    

    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        /* Grab current velocity */
        let velocityY = hero.physicsBody?.velocity.dy ?? 0

        /* Check and cap vertical velocity */
        if velocityY > 400 {
          hero.physicsBody?.velocity.dy = 400
            
        /* Apply falling rotation */
        let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
        let scrollSpeed: CGFloat = 100
        
        if sinceTouch > 0.2 {
            let impulse = -20000 * fixedDelta
            hero.physicsBody?.applyAngularImpulse(CGFloat(impulse))
        }

        /* Clamp rotation */
        hero.zRotation.clamp(v1: CGFloat(-90).degreesToRadians(), CGFloat(30).degreesToRadians())
        hero.physicsBody?.angularVelocity.clamp(v1: -1, 3)

        /* Update last touch timer */
        sinceTouch += fixedDelta
            
        func scrollWorld() {
          /* Scroll World */
          scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
            /* Loop through scroll layer nodes */
            for ground in scrollLayer.children as! [SKSpriteNode] {

              /* Get ground node position, convert node position to scene space */
              let groundPosition = scrollLayer.convert(ground.position, to: self)

              /* Check if ground sprite has left the scene */
              if groundPosition.x <= -ground.size.width / 2 {

                  /* Reposition ground sprite to the second starting position */
                  let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)

                  /* Convert new node position back to scroll layer space */
                  ground.position = self.convert(newPosition, to: scrollLayer)
              }
            }
        }
            func updateObstacles() {
              /* Update Obstacles */

              obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)

              /* Loop through obstacle layer nodes */
              for obstacle in obstacleLayer.children as! [SKReferenceNode] {

                  /* Get obstacle node position, convert node position to scene space */
                  let obstaclePosition = obstacleLayer.convert(obstacle.position, to: self)

                  /* Check if obstacle has left the scene */
                  if obstaclePosition.x <= -26 {
                  // 26 is one half the width of an obstacle

                      /* Remove obstacle node from obstacle layer */
                      obstacle.removeFromParent()
                  }

              }
                /* Time to add a new obstacle? */
                if spawnTimer >= 1.5 {

                    /* Create a new obstacle by copying the source obstacle */
                    let newObstacle = obstacleSource.copy() as! SKNode
                    obstacleLayer.addChild(newObstacle)

                    /* Generate new obstacle position, start just outside screen and with a random y value */
                    let randomPosition =  CGPoint(x: 347, y: CGFloat.random(in: 234...382))

                    /* Convert new node position back to obstacle layer space */
                    newObstacle.position = self.convert(randomPosition, to: obstacleLayer)

                    // Reset spawn timer
                    spawnTimer = 0
                }
            }
        /* Process world scrolling */
        scrollWorld()
            
        /* Process obstacles */
        updateObstacles()
            
        spawnTimer+=fixedDelta
    }
}
}
