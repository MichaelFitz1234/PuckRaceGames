//
//  CreateGameScreen.swift
//  RapidShotLightAR
//
//  Created by Michael  on 7/25/22.
//

import Foundation
import UIKit
struct CreateGameScreen {
    var gameTitle: String?
    var instructionsForGame: String?
    var numOfShots:String?
    var topRightImage:UIImage?
    var bottomImage: UIImage?
    var buttonOne:Int?
    var buttonTwo:Int?
    var buttonThree:Int?
    var idType:Int?
    init(gameTitle: String, instructionsForGame: String, numOfShots: String, bottomImage: UIImage, topRightImage: UIImage, buttonOne: Int, buttonTwo: Int, buttonThree: Int, idType: Int) {
        self.gameTitle = gameTitle
        self.instructionsForGame = instructionsForGame
        self.numOfShots = numOfShots
        self.topRightImage = topRightImage
        self.bottomImage = bottomImage
        self.buttonOne = buttonOne
        self.buttonTwo = buttonTwo
        self.buttonThree = buttonThree
        self.idType = idType
    }
}
