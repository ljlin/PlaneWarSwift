//
//  GameScene.swift
//  PlaneWarSwift
//
//  Created by ljlin on 14-6-7.
//  Copyright (c) 2014年 ljlin. All rights reserved.
//

import SpriteKit
import Foundation

let ENEMIES_MAX_COUNT    = 100
let BULLET_RATE          = 10

let ENEMY_MIDDIUM_RATE   = 10
let ENEMY_LARGE_RATE     = 21

class GameScene: SKScene,SKPhysicsContactDelegate {
    var player  = PlayerSprite()
    let background = SKSpriteNode(imageNamed:"bg")
    var score  = 0
    let scoreLabel = SKLabelNode()
    var enemiesArray = Optional<EnemySprite>[]()
    var bullet_setup_count = 0
    override func didMoveToView(view: SKView) {
        self.setUpPlayer()
        self.setUpEnemies()
        self.physicsWorld.contactDelegate = self
        background.setScale(0.5)
        background.anchorPoint = CGPointMake(0.5,0.5)
        background.position = CGPointMake(self.size.width / 2 , self.size.height / 2)
        self.addChild(background)
        self.addScoreLabel()
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch =  touches.anyObject() as UITouch
        let location = touch.locationInNode(self)
        if ((abs(location.x-player.position.x)<=50) &&
            (abs(location.y-player.position.y)<=50)){
            player.position = location
        }
    }
    override func update(currentTime:CFTimeInterval) {
        self.setUpOneBullet()
        self.addEnemies()
    }
    func restart(){
        score = 0;
        self.updateScore()
        for sprite in enemiesArray{
            if sprite {
                sprite!.removeFromParent()
                sprite!.removeAllActions()
                sprite!.blood = sprite!.maxBlood
            }
        }
        //self.removeChildrenInArray
        self.setUpEnemies()
    }

    func addScoreLabel() {
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.text = "0"
        scoreLabel.fontSize = 20
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame) - 45)
        scoreLabel.zPosition = 10
        self.addChild(scoreLabel)
    }
    func setUpPlayer() {
        player = PlayerSprite.newPlayerAtPostion(CGPointMake(CGRectGetMidX(self.frame),50))
        player.zPosition = 10.0
        player.setScale(0.4)
        self.addChild(player)
    }
    func setUpOneBullet() {
        if (bullet_setup_count >= BULLET_RATE) {
            bullet_setup_count = 0
        } else {
            bullet_setup_count++
            return
        }
        var position = player.position
        var bullet = BulletSprite.newBulletWithType(BulletTypeNormal,position:position)
        self.addChild(bullet)
        var dest  = CGPointMake(position.x, CGRectGetHeight(self.frame))
        var time = Double(fabs(Double(dest.y) - Double(position.y))) / Double(bullet.speed)
        var action = SKAction.moveTo(dest,duration:time)
        bullet.runAction(action,completion:{bullet.removeFromParent()})
    }
    func setUpEnemies() {
        for i in 0..ENEMIES_MAX_COUNT {
            var sprite : EnemySprite?
            if (i % ENEMY_LARGE_RATE == 0) {
                sprite = EnemySprite.newEnemyWithEnemyType(EnemyTypeLarge)
            } else if (i % ENEMY_MIDDIUM_RATE == 0) {
                sprite = EnemySprite.newEnemyWithEnemyType(EnemyTypeMiddium)
            } else {
                sprite = EnemySprite.newEnemyWithEnemyType(EnemyTypeSmall)
            }
            if (sprite?.parent != self) {
                enemiesArray += sprite
            }
        }
    }
    func updateScore() {scoreLabel.text = "\(score)"}
    func availabelSprite() -> EnemySprite? {
        let rand_count = random() % enemiesArray.count
        var sprite :EnemySprite? = enemiesArray[rand_count]
        
        if let msprite = sprite {
            if(msprite.parent != self){
                msprite.removeAllActions()
                return msprite
            }
        }
        return nil
    }
    func addEnemies() {
        if let sprite = self.availabelSprite(){
            if (random() % 50 == 0) {
                let x = (CGFloat(random()) % 1000) / 1000 * CGFloat(self.size.width)
                //CGFloat(random() % 1000) * CGFloat(((CGRectGetMaxX(self.frame) - sprite.size.width ) / 1000) + sprite.size.width / 2)
                let position = CGPointMake(x, CGRectGetMaxY(self.frame) + sprite.size.height)
                sprite.position = position
                let dest = CGPointMake(x, -sprite.size.height)
                self.addChild(sprite)
                let time = Double(fabs(Double(dest.y) - Double(position.y))) / Double(sprite.speed)
                let action = SKAction.moveTo(dest,duration:time)
                sprite.runAction(action,completion:{
                    sprite.removeFromParent()
                    sprite.blood = sprite.maxBlood
                    })
                }
        }
    }
    func didBeginContact(contact: SKPhysicsContact!){
        if ((contact.bodyA.node is PlayerSprite == true) ||
            (contact.bodyB.node is PlayerSprite == true)){
                self.restart()
        } else {
            var sprite : EnemySprite!  = nil
            var bullet : BulletSprite! = nil
            if contact.bodyA.node is EnemySprite {
                sprite = contact.bodyA.node as EnemySprite
                bullet = contact.bodyB.node as BulletSprite
            } else {
                sprite = contact.bodyB.node as EnemySprite
                bullet = contact.bodyA.node as BulletSprite
            }
            sprite.blood = sprite.blood - bullet.power
            if (sprite.blood <= 0) {
                sprite.removeFromParent()
                sprite.removeAllActions()
                sprite.blood = sprite.maxBlood
                self.score += Int(sprite.score())
                self.updateScore()
            }
            bullet.removeFromParent()
            bullet.removeAllActions()
        }
    }
}