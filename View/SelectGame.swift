//
//  SelectGame.swift
//  RapidShotLightAR
//
//  Created by Michael  on 7/25/22.
//

import UIKit
protocol CardViewDelegate {
    func nextCardRight(translation: CGFloat)
    func nextCardLeft(translation: CGFloat)
    
}

class SelectGame: UIView{
    var nextCard: SelectGame?
    var previousCard: SelectGame?
    var delegate: CardViewDelegate?
    var id = 0
    var value: CreateGameScreen?
    var whichSelect = 1
    fileprivate lazy var screenSize = UIScreen.main.bounds
    fileprivate lazy var ScreenWidth = screenSize.width+20
    fileprivate let threshold: CGFloat = 100
    fileprivate let locationUsername = UILabel()
    fileprivate let topView = UIView()
    fileprivate let bottomView = UIView()
    fileprivate let target = UIImageView()
    fileprivate let gameTitle = UILabel()
    fileprivate let numberOfShots = UILabel()
    fileprivate let selectNumShots = UILabel()
    fileprivate let button1 = UIButton(type: .system)
    fileprivate let button2 = UIButton(type: .system)
    fileprivate let button3 = UIButton(type: .system)
    fileprivate let bottomImgView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
    }
    func nextCardSetup(){
        let rotationalTransformation = CGAffineTransform(rotationAngle: 0)
        nextCard?.transform = rotationalTransformation.translatedBy(x: ScreenWidth, y: 0)
    }
    func lastCardSetup(){
        let rotationalTransformation = CGAffineTransform(rotationAngle: 0)
        previousCard?.transform = rotationalTransformation.translatedBy(x: -ScreenWidth, y: 0)
    }
    fileprivate func handleEnded(gesture: UIPanGestureRecognizer) {
            let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
            let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold
            if shouldDismissCard {
                if translationDirection == 1{
                    if previousCard == nil{
                        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                            self.transform = .identity
                            let rotationalTransformation = CGAffineTransform(rotationAngle: 0)
                            self.nextCard?.transform = rotationalTransformation.translatedBy(x: self.ScreenWidth, y: 0)
                            self.previousCard?.transform = rotationalTransformation.translatedBy(x: -self.ScreenWidth, y: 0)
                        })
                    }else{
                        self.delegate?.nextCardLeft(translation: -700)
                    }
                } else if translationDirection == -1{
                    if nextCard == nil{
                        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                            self.transform = .identity
                            let rotationalTransformation = CGAffineTransform(rotationAngle: 0)
                            self.nextCard?.transform = rotationalTransformation.translatedBy(x: self.ScreenWidth, y: 0)
                            self.previousCard?.transform = rotationalTransformation.translatedBy(x: -self.ScreenWidth, y: 0)
                        })
                    } else {
                        self.delegate?.nextCardRight(translation: 700)
                    }
                }
            } else {
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                    self.transform = .identity
                    let rotationalTransformation = CGAffineTransform(rotationAngle: 0)
                    self.nextCard?.transform = rotationalTransformation.translatedBy(x: self.ScreenWidth, y: 0)
                    self.previousCard?.transform = rotationalTransformation.translatedBy(x: -self.ScreenWidth, y: 0)
                })
            }
        }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let rotationalTransformation = CGAffineTransform(rotationAngle: 0)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: 0)
        nextCard?.transform = rotationalTransformation.translatedBy(x: translation.x+ScreenWidth, y: 0)
        previousCard?.transform = rotationalTransformation.translatedBy(x: translation.x-ScreenWidth, y: 0)
    }
    func setupLayout(){
        layer.cornerRadius = 10
        clipsToBounds = true
        addSubview(topView)
        addSubview(bottomView)
        addSubview(target)
        addSubview(gameTitle)
        addSubview(numberOfShots)
        addSubview(selectNumShots)
        addSubview(button1)
        addSubview(button2)
        addSubview(button3)
        topView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        topView.heightAnchor.constraint(equalToConstant: screenSize.height/4.5).isActive = true
        topView.backgroundColor = .systemGray6
        bottomView.anchor(top: topView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        bottomView.backgroundColor = UIColor(hexString: "030105")
        target.anchor(top: topView.topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor ,padding: .init(top: -10, left: 0, bottom: 0, right: -10), size: .init(width: 80, height: 80))
        gameTitle.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 10, left: 5, bottom: 0, right: 10))
        gameTitle.font = .boldSystemFont(ofSize: 24)
        numberOfShots.anchor(top: gameTitle.bottomAnchor, leading: gameTitle.leadingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 30, left: 10, bottom: 0, right: 20))
        numberOfShots.numberOfLines = 0
        selectNumShots.anchor(top: bottomView.topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 30, left: 0, bottom: 0, right: 0))
        selectNumShots.textAlignment = .center
        selectNumShots.textColor = .white
        button1.anchor(top: selectNumShots.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 20, left: 40, bottom: 0, right: 0),size: .init(width: 60, height: 60))
        button1.layer.cornerRadius = 10
        button1.titleLabel?.font = .systemFont(ofSize: 22)
        button1.setTitleColor(.white, for: .normal)
        button1.backgroundColor = .black
        button1.addTarget(self, action: #selector(lightUp), for: .touchUpInside)
        button2.anchor(top: selectNumShots.bottomAnchor, leading: button1.trailingAnchor, bottom: nil, trailing: nil,padding: .init(top: 20, left: 20, bottom: 0, right: 0),size: .init(width: 60, height: 60))
        button2.backgroundColor = .white
        button2.layer.cornerRadius = 10
        button2.setTitleColor(.black, for: .normal)
        button2.titleLabel?.font = .systemFont(ofSize: 22)
        button2.addTarget(self, action: #selector(lightUp1), for: .touchUpInside)
        button3.anchor(top: selectNumShots.bottomAnchor, leading:  button2.trailingAnchor, bottom: nil, trailing: nil,padding: .init(top: 20, left: 20, bottom: 0, right: 0),size: .init(width: 60, height: 60))
        button3.setTitleColor(.black, for: .normal)
        button3.backgroundColor = .white
        button3.layer.cornerRadius = 10
        button3.titleLabel?.font = .systemFont(ofSize: 22)
        button3.addTarget(self, action: #selector(lightUp2), for: .touchUpInside)
        addSubview(bottomImgView)
        bottomImgView.anchor(top: button1.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 10, left: 80, bottom: 0, right: 0), size: .init(width: 160, height: 160))
     }
    @objc func lightUp(){
        button1.setTitleColor(.black, for: .normal)
        button1.backgroundColor = .white
        button2.setTitleColor(.black, for: .normal)
        button2.backgroundColor = .white
        button3.setTitleColor(.black, for: .normal)
        button3.backgroundColor = .white
        whichSelect = 1
        button1.setTitleColor(.white, for: .normal)
        button1.backgroundColor = .black
    }
    @objc func lightUp1(){
        button1.setTitleColor(.black, for: .normal)
        button1.backgroundColor = .white
        button2.setTitleColor(.black, for: .normal)
        button2.backgroundColor = .white
        button3.setTitleColor(.black, for: .normal)
        button3.backgroundColor = .white
        whichSelect = 2
        button2.setTitleColor(.white, for: .normal)
        button2.backgroundColor = .black
    }
    
    @objc func lightUp2(){
        button1.setTitleColor(.black, for: .normal)
        button1.backgroundColor = .white
        button2.setTitleColor(.black, for: .normal)
        button2.backgroundColor = .white
        button3.setTitleColor(.black, for: .normal)
        button3.backgroundColor = .white
        whichSelect = 3
        button3.setTitleColor(.white, for: .normal)
        button3.backgroundColor = .black
    }
    
     func createFromOutline(createGameScreen: CreateGameScreen){
        gameTitle.text = createGameScreen.gameTitle
        numberOfShots.text = createGameScreen.instructionsForGame
        selectNumShots.text = createGameScreen.numOfShots
        //bottomImg = createGameScreen.bottomImage
        bottomImgView.image = createGameScreen.bottomImage
        target.image = createGameScreen.topRightImage
        button1.setTitle(String(createGameScreen.buttonOne!), for: .normal)
        button2.setTitle(String(createGameScreen.buttonTwo!), for: .normal)
        button3.setTitle(String(createGameScreen.buttonThree!), for: .normal)
        id = createGameScreen.idType ?? 0
        value = createGameScreen
        //"Select Number Of Shots:"
        //"Top shot will determine where you hit the goal and give you points depending on how accurate you are."

    }
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer){
        switch gesture.state {
        case .began:
            //
            superview?.subviews.forEach({ (subview) in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture: gesture)
        default:
            ()
        }
    }
    required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
   
}
