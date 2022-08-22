//
//  mainController.swift
//  RapidShotLightAR
//
//  Created by Michael  on 7/25/22.
//

import UIKit

class mainController: UINavigationController, gameSelectedProtocol,endGame {
    func gameEnded(numberOfShots: Int, timeTaken: Double) {
        let myTopView = Summary()
        myTopView.totalTimeCount = timeTaken
        myTopView.numberOfHits = numberOfShots
        //myTopView.delegate = self
//        let transition = CATransition()
//        transition.duration = 0.25
//        transition.type = CATransitionType.push
//        transition.subtype = CATransitionSubtype.fromRight
//        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
//        view.window!.layer.add(transition, forKey: kCATransition)
        popViewController(animated: false)
        pushViewController(myTopView, animated: false)
    }
    
    func gameSelected(gameId: Int, typeId: Int) {
        if(gameId == 0){
        let myTopView = StickTrackingRapidHands()
        //myTopView.numberOfTargets = typeId
        //myTopView.delegate = self
//        let transition = CATransition()
//        transition.duration = 0.25
//        transition.type = CATransitionType.push
//        transition.subtype = CATransitionSubtype.fromRight
//        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
//        view.window!.layer.add(transition, forKey: kCATransition)
        popViewController(animated: false)
        pushViewController(myTopView, animated: false)
        }else if (gameId == 1){
            let myTopView = RandomStickTracking()
            myTopView.numberOfTargets = typeId
            myTopView.delegate = self
    //        let transition = CATransition()
    //        transition.duration = 0.25
    //        transition.type = CATransitionType.push
    //        transition.subtype = CATransitionSubtype.fromRight
    //        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
    //        view.window!.layer.add(transition, forKey: kCATransition)
            popViewController(animated: false)
            pushViewController(myTopView, animated: false)
        }else if(gameId == 2){
            let myTopView = SurvivalStickTracking()
            myTopView.numberOfLives = typeId
            myTopView.delegate = self
    //        let transition = CATransition()
    //        transition.duration = 0.25
    //        transition.type = CATransitionType.push
    //        transition.subtype = CATransitionSubtype.fromRight
    //        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
    //        view.window!.layer.add(transition, forKey: kCATransition)
            popViewController(animated: false)
            pushViewController(myTopView, animated: false)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
