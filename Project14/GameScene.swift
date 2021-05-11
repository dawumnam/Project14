//
//  GameScene.swift
//  Project14
//
//  Created by Dawum Nam on 5/10/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var numRounds = 0
    
    var popupTime = 0.85
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        for index in 0..<5 { createSlot(at: CGPoint(x: (index * 170) + 100, y: 410)) }
        for index in 0..<4 { createSlot(at: CGPoint(x: (index * 170) + 180, y: 320)) }
        for index in 0..<5 { createSlot(at: CGPoint(x: (index * 170) + 100, y: 230)) }
        for index in 0..<4 { createSlot(at: CGPoint(x: (index * 170) + 180, y: 140)) }

        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [weak self] in self?.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let emitter = SKEmitterNode(fileNamed: "magicParticle.sks") else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        emitter.position = location

        

        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit()
            
            if node.name == "charFriend" {
                score -= 5
                addChild(emitter)
                run(SKAction.playSoundFileNamed("ouch.m4a", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                score += 1
                addChild(emitter)
                run(SKAction.playSoundFileNamed("Yack.m4a", waitForCompletion: false))
            }
        }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        if checkGameOver(maxRound: 50) { return }
        popupTime *= 0.999
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime) }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2.0
        
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            [weak self] in self?.createEnemy()
        }
    }
    
    func checkGameOver(maxRound: Int) -> Bool {
        numRounds += 1
        if numRounds >= maxRound {
            for slot in slots {
                slot.hide()
            }
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            let gameOverScore = SKLabelNode(text: "Your final score is:\(score)")
            //gameOverScore.fontName = "Chalkduster"
            gameOverScore.horizontalAlignmentMode = .center
            gameOverScore.fontColor = UIColor.black
            gameOverScore.fontSize = 48
            gameOverScore.position = CGPoint(x: 512, y: 384+58)
            gameOverScore.zPosition = 1
            addChild(gameOverScore)
            return true
        }
        return false
    }
    
    
}
