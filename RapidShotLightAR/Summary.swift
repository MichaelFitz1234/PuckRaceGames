//
//  Summary.swift
//  RapidShotLightAR
//
//  Created by Michael  on 8/3/22.
//

import UIKit

class Summary: UIViewController {
    var totalTimeCount = 0.0
    var numberOfHits = 0 {
        didSet {
            totalTime.text =  "The number of Targets Hit is: " + String(numberOfHits)
            numberOfTargetsHit.text = "The total time was: " +  String(totalTimeCount) + " Seconds"
        }
    }
    
    
    let myTitle = UILabel()
    let totalTime = UILabel()
    let numberOfTargetsHit = UILabel()
    let tableOfReactionTimes = UITableView()
    let continueButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(myTitle)
        view.addSubview(totalTime)
        view.addSubview(numberOfTargetsHit)
        //v//iew.addSubview(numberOfTargetsHit)
        view.addSubview(continueButton)
        myTitle.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 100, left: 0, bottom: 0, right: 0))
        myTitle.text = "Summary"
        myTitle.textAlignment = .center
        myTitle.font = .boldSystemFont(ofSize: 18)
        totalTime.anchor(top: myTitle.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 30, left: 0, bottom: 0, right: 0))
        totalTime.textAlignment = .center
        numberOfTargetsHit.anchor(top: totalTime.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 30, left: 0, bottom: 0, right: 0))
        numberOfTargetsHit.textAlignment = .center
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
