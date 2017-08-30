//
//  ViewController.swift
//  Match5
//
//  Created by YoderDaniel on 2017/08/22.
//  Copyright © 2017 YoderDaniel. All rights reserved.
//

import UIKit
import AVFoundation



class ViewController: UIViewController {
    
    let model = CardModel()
    var cards = [Card]()
    var revealedCard:Card?
    var timer:Timer?
    var countdown = 60
    
    var cardFlipSoundPlayer:AVAudioPlayer?
    var correctSoundPlayer:AVAudioPlayer?
    var wrongSoundPlayer:AVAudioPlayer?
    var shuffleSoundPlayer:AVAudioPlayer?
    
    
    
    
    
    var stackViewArray = [UIStackView]()
    
    @IBOutlet weak var firstStackView: UIStackView!
    @IBOutlet weak var secondStackView: UIStackView!
    @IBOutlet weak var thirdStackView: UIStackView!
    @IBOutlet weak var fourthStackView: UIStackView!
    @IBOutlet weak var countdownLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //create and initialize the sound players
        do {
        let shuffleSoundPath = Bundle.main.path(forResource: "shuffle" , ofType: "wav")
        let shuffleSoundUrl = URL(fileURLWithPath: shuffleSoundPath!)
        shuffleSoundPlayer = try  AVAudioPlayer(contentsOf: shuffleSoundUrl)
        
        } catch{
            
            //sound player couldnt be created
            }
        do {
            let cardFlipSoundPath = Bundle.main.path(forResource: "cardflip" , ofType: "wav")
            let cardFlipSoundUrl = URL(fileURLWithPath: cardFlipSoundPath!)
            cardFlipSoundPlayer = try  AVAudioPlayer(contentsOf: cardFlipSoundUrl)
            
        } catch{
            
            //sound player couldnt be created
        }
        
        do {
            let correctSoundPath = Bundle.main.path(forResource: "dingcorrect" , ofType: "wav")
            let correctSoundUrl = URL(fileURLWithPath: correctSoundPath!)
            shuffleSoundPlayer = try  AVAudioPlayer(contentsOf: correctSoundUrl)
            
        } catch{
            
            //sound player couldnt be created
        }
        
        do {
            let wrongSoundPath = Bundle.main.path(forResource: "dingwrong" , ofType: "wav")
            let wrongSoundUrl = URL(fileURLWithPath: wrongSoundPath!)
            wrongSoundPlayer = try  AVAudioPlayer(contentsOf: wrongSoundUrl)
            
        } catch{
            
            //sound player couldnt be created
        }
        
        
        //put the four stackViews into an array
        stackViewArray += [firstStackView, secondStackView, thirdStackView, fourthStackView]
        
        //get the cards
        cards = model.getCards()
        
        //layout the cards
        
        layoutCards()
        
        //set the countown label
        countdownLabel.text = String(countdown)
        
        //create and schedule a timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
        
        
    }
    
    func timerUpdate(){
        
        countdown -= 1
        
        if countdown == 0 {
            
            //stop the game
            timer?.invalidate()
            
            //check if the user has matched all the cards
            var userHasMatchedAllCards = true
            for card in cards {
                if card.isDone == false{
                    userHasMatchedAllCards = false
                    break
                }
                
            }
            
            var popUpMessage = ""
            
            if userHasMatchedAllCards == true{
            
            
            //game is won
            popUpMessage = "Won"
        }
            
        else
            {
                    //game is lost
                popUpMessage = "Lost"
            }
            
            //create alert
            let alert = UIAlertController(title: "Time's up", message: popUpMessage, preferredStyle: .alert)
            
            
            //create alert action
            let alertAction = UIAlertAction(title:"OK", style: .cancel, handler: { (alert) in
                self.restart()
            })
            //attach action to alert
            alert.addAction(alertAction)
            
            //present the alert
            present(alert, animated: true, completion: nil)
        }
        
        //update the label in the UI
        countdownLabel.text = String(countdown)
    }
    
    
    
    func layoutCards() {
        
        //play shuffle sound
        shuffleSoundPlayer?.play()
        
        //keeps track of which card we're at
        var cardIndex = 0
        
        // loop through the four stackviews and put four cards into each
        
        for stackview in stackViewArray {
            
            // Put four card objects into the StackView
            for _ in 1...4 {
                
                //check if card exsits at index before adding
                if cardIndex < cards.count{
                    
                    //Set card that we're looking at
                    let card = cards[cardIndex]
                    card.translatesAutoresizingMaskIntoConstraints = false
                    
                    //set a gesture recognizer and attach it to the card
                    let recognizer = UITapGestureRecognizer(target: self, action: #selector(cardTapped(gestureRecognizer:)) )
                    card.addGestureRecognizer( recognizer)
                    
                    
                    // set the size of the card object
                    let heightConstraint = NSLayoutConstraint(item: card, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 170)
                    
                    let widthConstraint = NSLayoutConstraint(item: card, attribute: .width, relatedBy: .equal, toItem: nil , attribute: .notAnAttribute, multiplier: 1, constant: 120)
                    
                    //add constraints
                    card.addConstraints([heightConstraint,widthConstraint])
                    
                    
                //put a crad into the stackview
                stackview.addArrangedSubview(cards[cardIndex])
                cardIndex += 1
                    
                }
            }
            
            
        }
    }
    
    func cardTapped(gestureRecognizer:UITapGestureRecognizer) {
        
        //check if countdown is 0
        if countdown == 0 {
            return
        }
        //play flip sound
        cardFlipSoundPlayer?.play()
        
        
        //card is tapped
       let card =  gestureRecognizer.view as! Card
        
        //check if the card is already flipped up
        
        if card.flippedUp == false {
            
            
            //reveal card
            
            card.flipUp()
            
            
            
            if revealedCard == nil {
            //this is the first card being flipped up
                
                //track this card as the first card being flipped up
                revealedCard = card
                
            }
                else {
                    //second card being flipped up
                
                if card.cardValue == revealedCard?.cardValue{
                    //cards match
                    
                    correctSoundPlayer?.play()
                    
                    //remove both cards from the grid
                    
                    card.isDone = true
                    revealedCard?.isDone = true
                    
                  //remove tracking from the first card
                    revealedCard = nil
                    
                    //check if all cards match
                    checkPairs()
                }
                 else {
                    //cards don't match
                    wrongSoundPlayer?.play()
                    
                    let _ = Timer.scheduledTimer(timeInterval: 1, target: card, selector: #selector(Card.flippedDown), userInfo: nil, repeats: false)
                    
                    let _ = Timer.scheduledTimer(timeInterval: 1, target: revealedCard!, selector: #selector(Card.flippedDown), userInfo: nil, repeats: false)
                    
                   
                    
                    //reset tracking from the first card
                    
                revealedCard = nil
                    
                }
                
            }
            
        }
        
        
        
        
    }
    
    func checkPairs() {
        
        //check if all the pairs have been matched
        var allDone = true
        
        for card in cards {
            if !card.isDone {
            allDone = false
                break;
            }
        }
        // check if it's all done
        if allDone{
            
            //stop the timer
            timer?.invalidate()
            
            //user has won
            
            //create alert
            let alert = UIAlertController(title: "All pairs match", message: "You Win!", preferredStyle: .alert)
            
            
            //create alert action
            let alertAction = UIAlertAction(title:"OK", style: .cancel, handler: { (alert) in
                self.restart()
            })
            //attach action to alert
            alert.addAction(alertAction)
            
            //present the alert
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    func restart() {
        
        
        
        //clear out all cards
        for card in cards {
            card.removeFromSuperview()
        }
        
        //get the cards
        cards = model.getCards()
        
        //layout the cards
        
        layoutCards()
        
        //set the countown label
        countdown = 40
        countdownLabel.text = String(countdown)
        
        //create and schedule a timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
        

        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

