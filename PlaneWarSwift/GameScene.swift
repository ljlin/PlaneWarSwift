//
//  GameScene.swift
//  PlaneWarSwift
//
//  Created by ljlin on 14-6-7.
//  Copyright (c) 2014年 ljlin. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var player  = SKSpriteNode(imageNamed:"plane")
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        player.position = myLabel.position
        player.xScale = 0.3
        player.yScale = 0.3
        self.addChild(player)
        self.addChild(myLabel)
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch =  touches.anyObject()
        let location = touch.locationInNode(self)
        if ((abs(location.x-player.position.x)<=50) &&
            (abs(location.y-player.position.y)<=50)){
            player.position = location
        }
        
    }




}