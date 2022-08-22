//
//  StickTrackingViewController.swift
//  RapidShotLightAR
//
//  Created by Michael  on 7/26/22.
//

import UIKit
import UIKit
import AVKit
import Vision
import AVFoundation
import LBTATools
import CoreML

class SurvivalStickTracking: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    var session: AVCaptureSession!
    var whichRectangle = -1
    var count = 0
    var level = 1
    var numberOfLives = 0
    var delegate:endGame?
    private var mode = 2
    let countLabel = UILabel()
    let startButton = UIButton()
    var firstDetect = 1
    var timeValueLabel: UILabel!
    private var initialRectObservations = [VNRecognizedObjectObservation]()
    private var cameraFeedView: CameraFeedView!
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInitiated,
                                                     attributes: [], autoreleaseFrequency: .workItem)
    private var orientation = CGImagePropertyOrientation.up
    private var cameraFeedSession: AVCaptureSession?
    var myRect:CGRect!
    var something: DRAW!
    
    let timeLeftShapeLayer = CAShapeLayer()
    let bgShapeLayer = CAShapeLayer()
    var timeLeft: TimeInterval = 3
    var endTime: Date?
    var timeLabel =  UILabel()
    fileprivate lazy var screenSize = UIScreen.main.bounds
    fileprivate lazy var ScreenWidth = ((screenSize.width)+20)
    var RapidHands = [CGRect]()
    var RapidHandsViews = [UIView]()
    // here you create your basic animation object to animate the strokeEnd
    let strokeIt = CABasicAnimation(keyPath: "strokeEnd")
    func drawBgShape() {
        bgShapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX , y: view.frame.midY), radius:
            100, startAngle: -90.degreesToRadians, endAngle: 270.degreesToRadians, clockwise: true).cgPath
        bgShapeLayer.strokeColor = UIColor.white.cgColor
        bgShapeLayer.fillColor = UIColor.clear.cgColor
        bgShapeLayer.lineWidth = 15
        view.layer.addSublayer(bgShapeLayer)
    }
    func drawTimeLeftShape() {
        timeLeftShapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX , y: view.frame.midY), radius:
            100, startAngle: -90.degreesToRadians, endAngle: 270.degreesToRadians, clockwise: true).cgPath
        timeLeftShapeLayer.strokeColor = UIColor.red.cgColor
        timeLeftShapeLayer.fillColor = UIColor.clear.cgColor
        timeLeftShapeLayer.lineWidth = 15
        view.layer.addSublayer(timeLeftShapeLayer)
    }
    func addTimeLabel() {
        timeLabel = UILabel(frame: CGRect(x: view.frame.midX-50 ,y: view.frame.midY-25, width: 100, height: 50))
        timeLabel.textAlignment = .center
        timeLabel.text = timeLeft.time
        view.addSubview(timeLabel)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
    override func viewDidAppear(_ animated: Bool) {
    AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight, andRotateTo: UIInterfaceOrientation.landscapeRight)

    do {try setupAVSession()}
    catch {
        AppError.display(error, inViewController: self)
        }
    myRect = CGRect(x: 300, y: 300, width: 30, height: 30)
        view.addSubview(startButton)
        startButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 50, right: 350), size: .init(width: 150, height: 80))
        startButton.setTitle("Start Session", for: .normal)
        startButton.backgroundColor = .blue
        startButton.layer.cornerRadius = 10
        startButton.addTarget(self, action: #selector(readForStuff), for: .touchUpInside)
    }
    fileprivate func addConfigs(){
        //print("method1")
        let width = Int(screenSize.height) - 100
        let randomIntX = Int.random(in: 100..<600)
        let randomIntY = Int.random(in: 0..<width)
        RapidHands.append(generateRapidHands(startX: randomIntX, startY: randomIntY, time: Double(level + 5)))
     
//        RapidHands.append(generateRapidHands(startX: 200, startY: Int(screenSize.height) - 100))
//        RapidHands.append(generateRapidHands(startX: 400, startY: 50))
//        RapidHands.append(generateRapidHands(startX: 400, startY: Int(screenSize.height) - 100))
        //RapidHands.append(generateRapidHands(startX: Int(screenSize.width/2), startY: Int(screenSize.height)/2 - 25))
//        RapidHands.append(generateRapidHands(startX: Int(screenSize.width) + 150, startY: 50))
//        RapidHands.append(generateRapidHands(startX: Int(screenSize.width) - 150, startY: Int(screenSize.height) - 100))
//
    }
    fileprivate func generateRapidHands(startX: Int, startY: Int, time: Double) -> CGRect{
        let rect1 = CGRect(x: startX, y: startY, width: 50, height: 50)
        let myRect1 = DRAW(frame: rect1)
        myRect1.backgroundColor = .yellow
        myRect1.layer.masksToBounds = true
        myRect1.layer.cornerRadius = 25
        UIView.animate(withDuration: 1.5, animations: {
            myRect1.alpha = 0
        })
        view.addSubview(myRect1)
        RapidHandsViews.append(myRect1)
        return rect1
    }
    fileprivate func startCountDown(){

    }
    
    weak var timer: Timer?
    var startTime: Double = 0
    var time: Double = 0
    @objc func advanceTimer(timer: Timer) {

       //Total time since timer started, in seconds
       time = Date().timeIntervalSinceReferenceDate - startTime

       //The rest of your code goes here

       //Convert the time to a string with 2 decimal places
       let timeString = String(format: "%.2f", time)

       //Display the time string to a label in our view controller
       timeValueLabel.text = timeString
     }
    @objc private func readForStuff(){
        if(firstDetect == 1){
          startButton.removeFromSuperview()
          view.addSubview(countLabel)
            countLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor,  padding: .init(top: 10, left: 300, bottom: 0, right: 300))
            countLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
            countLabel.text =  "Lives Remaining" + String(count) + " / " + String(numberOfLives)
            countLabel.backgroundColor = .blue
            countLabel.textColor = .white
            countLabel.textAlignment = .center
           mode = 2
           count = numberOfLives
          addConfigs()
          whichRectangle = 1
          timeValueLabel = UILabel()
          view.addSubview(timeValueLabel)
            timeValueLabel.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor,padding: .init(top: 20, left: 0, bottom: 0, right: 80))
            timeValueLabel.textColor = .white
            timeValueLabel.backgroundColor = .blue
          startTime = Date().timeIntervalSinceReferenceDate
          timer = Timer.scheduledTimer(timeInterval: 0.05,
                                     target: self,
                                     selector: #selector(advanceTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
        }else if(firstDetect == 2){
            let tooManyObj = UILabel()
            view.addSubview(tooManyObj)
            tooManyObj.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
            tooManyObj.textAlignment = .center
            tooManyObj.text = "Too many pucks in the scene make sure there is one"
            tooManyObj.font = .boldSystemFont(ofSize: 18)
            UIView.animate(withDuration: 2, animations: {
                tooManyObj.alpha = 0
            })
        }else{
            let tooManyObj = UILabel()
            view.addSubview(tooManyObj)
            tooManyObj.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
            tooManyObj.textAlignment = .center
            tooManyObj.text = "No pucks found in scene"
            tooManyObj.font = .boldSystemFont(ofSize: 18)
            UIView.animate(withDuration: 2, animations: {
                tooManyObj.alpha = 0
            })
        }
    }
    let model = try! VNCoreMLModel(for: puckTryTwo_1().model)
   //:MARK this is the sample buffer for the stuff
   // var request: VNRequest
    var isFirst = false
    var myDetect:VNDetectedObjectObservation!
    
    
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("fdsaj;ldfsj;ak")
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else
        {
            return
        }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        let rectangleDetectionRequest = VNCoreMLRequest(model: model)
        do {
            try imageRequestHandler.perform([rectangleDetectionRequest])
        } catch {
            
        }
        if let rectObservations = rectangleDetectionRequest.results as? [VNRecognizedObjectObservation] {

        initialRectObservations = rectObservations
        for (index, rectangleObservation) in initialRectObservations.enumerated() {
        DispatchQueue.main.async { [self] in
                let tracked = rectObservations.first?.boundingBox.origin
                let point = self.undoVideoFromRatio(point:CGPoint(x: tracked?.x ?? 0.0, y: tracked?.y ?? 0.0), rect: self.view.frame)
                //print(point)
                //let pointTwo = self.undoVideoFromRatio(point:CGPoint(x: tracked?.x ?? 0.0, y: tracked?.y ?? 0.0), rect: self.view.frame)
                //print(pointTwo)
                let width1 = ((rectObservations.first?.boundingBox.width ?? 0.0) * (self.view.frame.width))
                let height1 = ((rectObservations.first?.boundingBox.height ?? 0.0)  * (self.view.frame.height))
                let checkFrame = CGRect(x: point.x + 27, y: point.y - height1 - 12, width: width1 / 1.5, height: height1)
            //view.addSubview(DRAW(frame: checkFrame))
                if(whichRectangle != -1){
                if(checkFrame.intersects(self.RapidHandsViews[0].frame)){
                    let width = Int(screenSize.height) - 100
                    var randomIntX = Int.random(in: 100..<600)
                    var randomIntY = Int.random(in: 0..<width)
                    while(100 >= abs(Int(RapidHandsViews[0].frame.minX) - randomIntX)){
                        randomIntX = Int.random(in: 100..<600)
                    }
                    while(100 >= abs(Int(RapidHandsViews[0].frame.minX) - randomIntY)){
                        randomIntY = Int.random(in: 0..<width)
                    }
                    self.RapidHandsViews[0].removeFromSuperview()
                    RapidHandsViews.removeAll()
                    RapidHands.removeAll()
                    RapidHands.append(generateRapidHands(startX: randomIntX, startY: randomIntY, time: Double(level + 10)))
                    countLabel.text = "Number of Lives Remaining " + String(count) + " / " + String(numberOfLives)
                    }
                    if(count == 0){
                        self.delegate?.gameEnded(numberOfShots: numberOfLives, timeTaken: time)
                    }
                }
            }
        }
        }
    }
    func undoVideoFromRatio(point: CGPoint, rect: CGRect) -> CGPoint{
        return CGPoint(x: ((point.x * rect.width) + rect.minX), y: (rect.maxY - (point.y  *  (rect.height))))
    }
    func undoVideoFromRatioInverted(point: CGPoint, rect: CGRect) -> CGPoint{
        var pointY = rect.maxY - (point.y  *  (rect.height))
        if(pointY > ScreenWidth/2){
            pointY = pointY - screenSize.height/2
        }else{
            pointY = pointY + screenSize.height/2
        }
        
        return CGPoint(x: ((point.x * rect.width) + rect.minX), y: pointY)
    }
    func configureCameraForHighestFrameRate(device: AVCaptureDevice) {
        
        var bestFormat: AVCaptureDevice.Format?
        var bestFrameRateRange: AVFrameRateRange?

        for format in device.formats {
            for range in format.videoSupportedFrameRateRanges {
                if range.maxFrameRate == 240{
                    bestFormat = format
                    bestFrameRateRange = range
                    //print(range)
                    break;
                }
            }
        }
        
        if let bestFormat = bestFormat,
           let bestFrameRateRange = bestFrameRateRange {
            do {
                try device.lockForConfiguration()
                
                // Set the device's active format.
                device.activeFormat = bestFormat
                
                // Set the device's min/max frame duration.
                let duration = bestFrameRateRange.minFrameDuration
                device.activeVideoMinFrameDuration = duration
                device.activeVideoMaxFrameDuration = duration
                
                device.unlockForConfiguration()
            } catch {
                // Handle error.
            }
        }
    }
    func setupVideoOutputView(_ videoOutputView: UIView) {
        videoOutputView.translatesAutoresizingMaskIntoConstraints = false
        videoOutputView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //videoOutputView.transform = videoOutputView.transform.rotated(by: CGFloat(M_PI))
        view.addSubview(videoOutputView)
        NSLayoutConstraint.activate([
            videoOutputView.leftAnchor.constraint(equalTo: view.leftAnchor),
            videoOutputView.rightAnchor.constraint(equalTo: view.rightAnchor),
            videoOutputView.topAnchor.constraint(equalTo: view.topAnchor),
            videoOutputView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            //rotate or not
        ])
    }
    
    func setupAVSession() throws {
        // Create device discovery session for a wide angle camera
        let wideAngle = AVCaptureDevice.DeviceType.builtInWideAngleCamera
        
        let device = AVCaptureDevice.default(wideAngle, for: .video, position: .back)!
        configureCameraForHighestFrameRate(device: device)
        //print(device.activeFormat)
        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        session = AVCaptureSession()
        session.beginConfiguration()
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [
                String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        let captureConnection = dataOutput.connection(with: .video)
        captureConnection?.preferredVideoStabilizationMode = .standard
        // Always process the frames
        captureConnection?.isEnabled = true
        session.commitConfiguration()
        cameraFeedSession = session
        
        // Get the interface orientaion from window scene to set proper video orientation on capture connection.
        let videoOrientation: AVCaptureVideoOrientation
        videoOrientation = .landscapeRight
        
        cameraFeedView = CameraFeedView(frame: view.bounds, session: session, videoOrientation: videoOrientation)
        //print("hello")
        setupVideoOutputView(cameraFeedView)
        cameraFeedSession?.startRunning()
        }
}


    


