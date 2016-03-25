//
//  GameViewController.swift
//  Swiftris
//
//  Created by Tyler Hall on 11/17/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate, GKGameCenterControllerDelegate {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    var scene: GameScene!
    var swiftris:Swiftris!
    
    
    var panPointReference:CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //config the view
        let skView = self.view as! SKView
        skView.multipleTouchEnabled = false
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("didTap:"))
        
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("didPan:"))
        
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("didSwipe:"))
        
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        
        self.view.addGestureRecognizer(swipeGestureRecognizer)
        
        
        
        //create/config the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        scene.tick = didTick
        
        scene.timedGame()
        
        swiftris = Swiftris()
        
        swiftris.delegate = self
        
        swiftris.beginGame()
        
        skView.presentScene(scene)
        
        
        //deleted overide from next line to resolve error during initial delete. may need later
        func prefersStatusBarHidden() -> Bool {
            return true
        }
        
        authenticateLocalPlayer()
        
    }


    func authenticateLocalPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            guard let viewController = viewController else {
                print("(GameCenter) Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
                
                return
            }
            
            self.presentViewController(viewController, animated: true, completion: nil)
            
            
        }
    }
    
    func saveHighscore (score: Int64) {
        if GKLocalPlayer.localPlayer().authenticated {
            let gkScore = GKScore(leaderboardIdentifier: "SwiftrisLeaderboard123")
            gkScore.value = score
            GKScore.reportScores([gkScore], withCompletionHandler: ( { (error: NSError?) -> Void in
                if let error = error {
                    // handle error
                    print("Error: " + error.localizedDescription);
                } else {
                    print("Score reported: \(gkScore.value)")
                }
            }))
        }

    }
    
    func showLeader() {
        let vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    func didTap(sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    
    func didPan(sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            // #3
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                // #4
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    func didSwipe(sender: UISwipeGestureRecognizer) {
        swiftris.dropShape()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // #6
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    func didTick() {
        swiftris.letShapeFall()
        
        if swiftris.mode == .timed {
            
            
            if scene.timedGame() {
                swiftris.endGame()
            }
        }
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
        self.scene.movePreviewShape(fallingShape) {
            // #16
            self.view.userInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = false
        scene.stopTicking()
        saveHighscore(swiftris.score)
        
        swiftris.score = 0
        swiftris.level = 1
        
        scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            //swiftris.beginGame()
        }
        
        showLeader()
   
        
        
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        
        self.view.userInteractionEnabled = false
        // #10
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // #11
                self.gameShapeDidLand(swiftris)
            }
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    // #17
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }
    
    
    
}
