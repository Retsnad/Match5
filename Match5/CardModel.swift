//
//  CardModel.swift
//  Match5
//
//  Created by YoderDaniel on 2017/08/22.
//  Copyright © 2017 YoderDaniel. All rights reserved.
//

import UIKit

class CardModel: NSObject {

    func getCards() -> [Card] {
        
        var cardArray = [Card]()
        
        for _ in 1...8 {
            
            let randomNumber = Int(arc4random_uniform(13))
            
            //generate card pair of objects
            
            let cardOne = Card()
            cardOne.cardValue = randomNumber
            
            let cardTwo = Card()
            cardTwo.cardValue = randomNumber
            
        
        //generate card objects
        
        //place card objects into card array
            
            cardArray += [cardOne, cardTwo]
            
        }
        
        //randomize the card array
        
        for index in 0...cardArray.count - 1 {
            
            //generate a random number
            
            let randomNumber = Int(arc4random_uniform(UInt32(cardArray.count)))
            
            let randomCard =  cardArray[randomNumber]
            
            //swap the objects
        cardArray[randomNumber] = cardArray[index]
            cardArray[index] = randomCard
            
            
            
        }
    
        return cardArray
    
    }
    
}
