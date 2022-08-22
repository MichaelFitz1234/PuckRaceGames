//
//  Select Skill Screen.swift
//  RapidShotLightAR
//
//  Created by Michael  on 7/25/22.
//

import UIKit
protocol gameSelectedProtocol{
    func gameSelected(gameId: Int, typeId: Int)
}
class Select_Skill_Screen: UIViewController, CardViewDelegate {
    var lastAddedPointer: SelectGame?
    var delegate:gameSelectedProtocol?
    var cardDeckHead: SelectGame?
    let dummycard = SelectGame()
    fileprivate lazy var screenSize = UIScreen.main.bounds
    fileprivate lazy var ScreenWidth = ((screenSize.width)+20)
    fileprivate var myView = UIView()
    let fillerUIView = UIView()
    func nextCardLeft(translation: CGFloat) {
            let duration = 0.3
            let translationAnimation = CABasicAnimation(keyPath: "position.x")
            translationAnimation.toValue = 700
            translationAnimation.duration = duration
            translationAnimation.fillMode = .forwards
            translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            translationAnimation.isRemovedOnCompletion = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseIn, animations: {
                self.cardDeckHead?.previousCard?.transform = .identity
            })
            cardDeckHead?.layer.add(translationAnimation, forKey: "translation")
            CATransaction.setCompletionBlock {
                let temp = self.cardDeckHead
                temp?.transform = .identity
                self.cardDeckHead?.removeFromSuperview()
                self.cardDeckHead = self.cardDeckHead?.previousCard
                self.cardDeckHead?.delegate = self
                temp?.nextCardSetup()
                self.cardDeckHead?.nextCard = temp
                self.cardDeckHead?.lastCardSetup()
                self.myView.addSubview(self.cardDeckHead?.nextCard ?? self.dummycard)
                self.myView.addSubview(self.cardDeckHead?.previousCard ?? self.dummycard)
                self.myView.sendSubviewToBack(self.cardDeckHead?.nextCard ?? self.dummycard)
                self.myView.sendSubviewToBack(self.cardDeckHead?.previousCard ?? self.dummycard)
                self.cardDeckHead?.nextCard?.fillSuperview()
                self.cardDeckHead?.previousCard?.fillSuperview()
            }
            CATransaction.commit()
        }
        func nextCardRight(translation: CGFloat) {
            let duration = 0.3
            let translationAnimation = CABasicAnimation(keyPath: "position.x")
            translationAnimation.toValue = -ScreenWidth
            translationAnimation.duration = duration
            translationAnimation.fillMode = .forwards
            translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            translationAnimation.isRemovedOnCompletion = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseIn, animations: {
                self.cardDeckHead?.nextCard?.transform = .identity
            })
            cardDeckHead?.layer.add(translationAnimation, forKey: "translation")
            CATransaction.setCompletionBlock {
                let temp = self.cardDeckHead
                temp?.transform = .identity
                self.cardDeckHead?.removeFromSuperview()
                self.cardDeckHead = self.cardDeckHead?.nextCard
                //self.cardDeckHead?.previousCard?.lastCardSetup()
                self.cardDeckHead?.delegate = self
                self.cardDeckHead?.nextCardSetup()
                temp?.lastCardSetup()
                self.cardDeckHead?.previousCard = temp
                self.myView.addSubview(self.cardDeckHead?.nextCard ?? self.dummycard)
                self.myView.addSubview(self.cardDeckHead?.previousCard ?? self.dummycard)
                self.myView.sendSubviewToBack(self.cardDeckHead?.previousCard ?? self.dummycard)
                self.myView.sendSubviewToBack(self.cardDeckHead?.nextCard ?? self.dummycard)
                self.cardDeckHead?.previousCard?.fillSuperview()
                self.cardDeckHead?.nextCard?.fillSuperview()
            }
            CATransaction.commit()
        }
    let quickPlay = UILabel()
    let selectTrainingMode = UILabel()
    let backArrow = UIImage(systemName: "chevron.left.circle")
    let backArrowImgView = UIImageView()
    let play = UIButton(type: .system)
    let selectGame = SelectGame()
    override func viewDidLoad() {
        super.viewDidLoad()
        //delegate = self
        //view.backgroundColor = UIColor(hexString: "09080C")
        view.addSubview(quickPlay)
        view.addSubview(selectTrainingMode)
        view.addSubview(backArrowImgView)
        view.addSubview(play)
        view.addSubview(selectGame)
        view.addSubview(myView)
        quickPlay.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor,padding: .init(top: -5, left: 0, bottom: 0, right: 0))
        quickPlay.text = "Start Training"
        quickPlay.textColor = .white
        quickPlay.textAlignment = .center
        quickPlay.font = .boldSystemFont(ofSize: 18)
        selectTrainingMode.anchor(top: quickPlay.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 30, left: 20, bottom: 0, right: 0))
        selectTrainingMode.text = "Select Mode:"
        selectTrainingMode.textColor = .white
        selectTrainingMode.font = .systemFont(ofSize: 16)
        play.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 80, bottom: 25, right: 80))
        play.heightAnchor.constraint(equalToConstant: 70).isActive = true
        play.setTitle("Begin", for: .normal)
        play.backgroundColor = .white
        play.setTitleColor(.black, for: .normal)
        play.layer.cornerRadius = 15
        play.layer.borderColor = UIColor.systemGray5.cgColor
        play.layer.borderWidth = 3
        play.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        myView.anchor(top: selectTrainingMode.topAnchor, leading: view.leadingAnchor, bottom: play.topAnchor, trailing: view.trailingAnchor,padding: .init(top: 50, left: 50, bottom: 30, right: 50))
        //selectGame.backgroundColor = .green
//        self.insertUsr(Card: SelectGame())
//        self.cardDeckHead?.removeFromSuperview()
//        self.myView.addSubview(self.cardDeckHead ?? self.fillerUIView)
//        self.cardDeckHead?.fillSuperview()
        let gameOne = SelectGame()
        let gameScreenOne = CreateGameScreen(gameTitle: "Targets Light Up", instructionsForGame: "In this game mode you will try to move the puck over a certain number of targets in as little time as possible", numOfShots: "Select Number targets:", bottomImage: UIImage(named: "stickIce")!, topRightImage:  UIImage(named: "target")!, buttonOne: 4, buttonTwo: 8, buttonThree: 12, idType: 0)
        gameOne.createFromOutline(createGameScreen: gameScreenOne)
        let gameScreenTwo = CreateGameScreen(gameTitle: "New Target", instructionsForGame: "In this game a new target will be generated and you will have to hit them:", numOfShots: "Select Number of Targets to Hit", bottomImage: UIImage(named: "stickIce")!, topRightImage:  UIImage(named: "HockeySticks")!, buttonOne: 4, buttonTwo: 8, buttonThree: 35, idType: 1)
        let gameTwo = SelectGame()
        gameTwo.createFromOutline(createGameScreen: gameScreenTwo)
        let gameScreenThree = CreateGameScreen(gameTitle: "Survival", instructionsForGame: "Try To keep yourself alive for as long as possible", numOfShots: "lives:", bottomImage: UIImage(named: "Stick Hero")!, topRightImage:  UIImage(named: "HockeySticks")!, buttonOne: 1, buttonTwo: 2,buttonThree: 3, idType: 2)
        let gameThree = SelectGame()
        gameThree.createFromOutline(createGameScreen: gameScreenThree)
        let gameScreenFour = CreateGameScreen(gameTitle: "Moving Targets", instructionsForGame: "In this game mode try to hit the moving targets", numOfShots: "num of targets:", bottomImage: UIImage(named: "Stick Hero")!, topRightImage:  UIImage(named: "HockeySticks")!, buttonOne: 1,buttonTwo: 2,buttonThree: 3, idType: 3)
        let gameFour = SelectGame()
        gameFour.createFromOutline(createGameScreen: gameScreenFour)
        self.addUser(CardView: gameOne)
        self.addUser(CardView: gameTwo)
        self.addUser(CardView: gameThree)
        self.addUser(CardView: gameFour)
        self.cardDeckHead?.delegate = self
        firstCardCreated()
        //cardDeckHead?.removeFromSuperview()
        //selectGame.delegate = self
    }
    @objc func startGame(){
        var number = 0
        if(cardDeckHead?.whichSelect == 1){
            number = (cardDeckHead?.value?.buttonOne)!
        }else if(cardDeckHead?.whichSelect == 2){
            number = (cardDeckHead?.value?.buttonTwo)!
        }else if(cardDeckHead?.whichSelect == 3){
            number = (cardDeckHead?.value?.buttonThree)!
        }
        self.delegate?.gameSelected(gameId: cardDeckHead?.id ?? 0, typeId: number)
    }
    fileprivate func addUser(CardView : SelectGame){
        let myNewNode = CardView
         if cardDeckHead == nil{
             cardDeckHead = myNewNode
             lastAddedPointer = myNewNode
             lastAddedPointer?.nextCard = nil
         }else{
             lastAddedPointer?.nextCard = myNewNode
             lastAddedPointer = myNewNode
             lastAddedPointer?.nextCard = nil
         }
     }
    fileprivate func firstCardCreated(){
        self.myView.addSubview(self.cardDeckHead ?? self.fillerUIView)
        self.myView.sendSubviewToBack(self.cardDeckHead ?? self.fillerUIView)
        self.cardDeckHead?.fillSuperview()
        self.cardDeckHead?.delegate = self
        self.cardDeckHead?.nextCardSetup()
        self.myView.addSubview(self.cardDeckHead?.nextCard ?? self.dummycard)
        self.myView.sendSubviewToBack(self.cardDeckHead?.nextCard ?? self.dummycard)
        self.cardDeckHead?.nextCard?.fillSuperview()
    }
    fileprivate func insertUsr(Card: SelectGame){
         let tempNode = cardDeckHead
         cardDeckHead = Card
         cardDeckHead?.nextCard = tempNode?.nextCard
         tempNode?.nextCard = Card
         cardDeckHead?.previousCard = tempNode
         tempNode?.previousCard?.removeFromSuperview()
     }
    override func viewWillAppear(_ animated: Bool) {
        setGradientBackground()
        super.viewWillAppear(animated)
    }
    func setGradientBackground() {
        let colorTop =  UIColor(red: 15/255.0, green: 10/255.0, blue: 10/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 80/255.0, green: 80/255.0, blue: 100/255.0, alpha: 1.0).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    private func setupLayout(){
        
    }

}
