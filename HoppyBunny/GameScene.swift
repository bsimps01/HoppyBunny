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
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        /* Recursive node search for 'hero' (child of referenced node) */
        hero = (self.childNode(withName: "//hero") as! SKSpriteNode)

        /* allows the hero to animate when it's in the GameScene */
        hero.isPaused = false
        
        /* Set reference to scroll layer node */
        scrollLayer = self.childNode(withName: "scrollLayer")
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
        /* Process world scrolling */
        scrollWorld()
    }
}
}
