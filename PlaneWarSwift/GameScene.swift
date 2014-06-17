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
let BULLET_RATE          = 15

let ENEMY_MIDDIUM_RATE   = 10
let ENEMY_LARGE_RATE     = 21

class GameScene: SKScene {
    var player  = PlayerSprite()
    let background = SKSpriteNode(imageNamed:"bg")
    var score  = 0
    let scoreLabel = SKLabelNode()
    var enemiesArray = Optional<EnemySprite>[]()

    override func didMoveToView(view: SKView) {
        
        self.setUpPlayer()
        self.setUpEnemies()
        
        background.setScale(0.8)
        background.anchorPoint = CGPointMake(0.5,0.5)
        background.position = CGPointMake(self.size.width / 2 , self.size.height / 2)
        self.addChild(background)
    
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
        //self.setUpOneBullet()
        self.addEnemies()
    }
    func setUpPlayer() {
        player = PlayerSprite.newPlayerAtPostion(CGPointMake(CGRectGetMidX(self.frame),50))
        player.zPosition = 10.0
        player.setScale(0.5)
        self.addChild(player)
    }
    var bullet_setup_count = 0
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
        var dest  = CGPointMake(position.x, position.y + CGRectGetHeight(self.frame) / 2.0)
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
        if (random() % 77 == 0) {
            let x :Float = Float(random() % 1000) * 0.1
            //let x = random() % 1000 * ((CGRectGetMaxX(self.frame) - sprite.size.width ) / 1000) + sprite.size.width / 2
            let position = CGPointMake(x, CGRectGetMaxY(self.frame) + sprite.size.height)
            player.position = position
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
}