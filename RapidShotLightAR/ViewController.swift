//
//  ViewController.swift
//  RapidShotLightAR
//
//  Created by Michael  on 7/18/22.
//

import UIKit
import AVKit
import Vision
import AVFoundation
import LBTATools
import CoreML
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate  {
    private var runningVector = VNPoint(x: 0.0, y: 0.0)
    private var possibleToPlot = [VNPoint]()
    private var lastTrajectoryID = UUID()
    private var isNewPath = true
    var session: AVCaptureSession!
    private var orientation = CGImagePropertyOrientation.up
    private lazy var detectTrajectoryRequest: VNDetectTrajectoriesRequest! =
                        VNDetectTrajectoriesRequest(frameAnalysisSpacing: .zero, trajectoryLength: 6)
    
    
    //this is used in order to createa a live feed of the video
    private var cameraFeedView: CameraFeedView!
    private var cameraFeedSession: AVCaptureSession?
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInitiated,
                                                     attributes: [], autoreleaseFrequency: .workItem)
    private var displayLink: CADisplayLink?
    var count = 0
    private var numberOfShot = 0
    let startButton = UIButton()
    let positionView = UILabel()
    let shotCount = UILabel()
    let ready = UILabel()
    var timestamp = Int64(0)
    var readyBool = false
    let model = findPuck_1()
    var mode = 0 {
        didSet {
            //ready
            if (mode == 2){
                DispatchQueue.main.async {
                    self.ready.text = "Read To Shoot!"
                }
            }
            if(mode == 1){
                DispatchQueue.main.async {
                    self.view.addSubview(self.ready)
                    self.ready.anchor(top: nil, leading: nil, bottom: self.view.bottomAnchor, trailing: self.view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 50, right: 350), size: .init(width: 150, height: 80))
                    self.ready.textAlignment = .center
                    self.ready.layer.masksToBounds = false
                    self.ready.layer.cornerRadius = 10
                    self.ready.textColor = .white
                    //self.ready.backgroundColor = .blue
                    self.ready.text = "Calibrating"
                }
            }
        }
    }
    var request: VNRequest!
    func setup() {
        let model = try! VNCoreMLModel(for: findPuck_1().model)
        request = VNCoreMLRequest(model: model)
    }

    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if(mode != 0){
        let timestampTwo = Date().currentTimeMillis()
        let visionHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: orientation, options: [:])
            do {
                try visionHandler.perform([self.detectTrajectoryRequest])
                if let results = self.detectTrajectoryRequest.results {
                    DispatchQueue.main.async { [self]
                        if(self.mode == 2){
                        self.processTrajectoryObservations(results)
                        }else{
                        if(!results.isEmpty){
                            self.timestamp = Date().currentTimeMillis()
                        }
                        if(timestampTwo - self.timestamp >= 2000){
                            self.mode = 2
                        }
                        if(self.mode == 2){
                        self.processTrajectoryObservations(results)
                        }
                        }
                    }
                }
            } catch {
                AppError.display(error, inViewController: self)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @objc private func readForStuff(){
        startButton.removeFromSuperview()
        positionView.removeFromSuperview()
        view.addSubview(shotCount)
        shotCount.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 30, left: 30, bottom: 0, right: 0), size: .init(width: 80, height: 50))
        shotCount.backgroundColor = .gray
        shotCount.text = "\(numberOfShot) / 4"
        timestamp = Date().currentTimeMillis()
        mode = 1
        //print(timestamp)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop capture session if it's running
        cameraFeedSession?.stopRunning()
        // Invalidate display link so it's removed from run loop
        displayLink?.invalidate()
    }
    override func viewDidAppear(_ animated: Bool) {
 
        do {try setupAVSession()}
        catch {
            AppError.display(error, inViewController: self)
        }
        view.addSubview(startButton)
        view.addSubview(positionView)
        positionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 50, left: 0, bottom: 0, right: 0))
        positionView.textAlignment = .center
        positionView.text = "Position Camera on Tripod for session then press start"
        startButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 50, right: 350), size: .init(width: 150, height: 80))
        startButton.setTitle("Start Session", for: .normal)
        startButton.backgroundColor = .blue
        startButton.layer.cornerRadius = 10
        startButton.addTarget(self, action: #selector(readForStuff), for: .touchUpInside)
        setup()
    }
    func calculateVector(pointOne: VNPoint, pointTwo: VNPoint) -> VNPoint{
        return VNPoint(x: pointTwo.x - pointOne.x, y: pointTwo.y - pointOne.y)
    }
    func setupVideoOutputView(_ videoOutputView: UIView) {
        videoOutputView.translatesAutoresizingMaskIntoConstraints = false
        videoOutputView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.addSubview(videoOutputView)
        NSLayoutConstraint.activate([
            videoOutputView.leftAnchor.constraint(equalTo: view.leftAnchor),
            videoOutputView.rightAnchor.constraint(equalTo: view.rightAnchor),
            videoOutputView.topAnchor.constraint(equalTo: view.topAnchor),
            videoOutputView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    func isVectorChange(vectorOne: VNPoint, vectorTwo: VNPoint) -> Bool{
        if(vectorOne.x < 0 && vectorTwo.x < 0 && vectorOne.y < 0 && vectorTwo.y < 0){
            return false;
        }else if(vectorOne.x < 0 && vectorTwo.x < 0 && vectorOne.y > 0 && vectorTwo.y > 0){
            return false;
        }else if(vectorOne.x > 0 && vectorTwo.x > 0 && vectorOne.y > 0 && vectorTwo.y > 0){
            return false;
        }else if(vectorOne.x > 0 && vectorTwo.x > 0 && vectorOne.y < 0 && vectorTwo.y < 0){
            return false;
        }else if(vectorOne.x > 0 && vectorTwo.x > 0 && vectorOne.y > 0 && vectorTwo.y < 0){
            return false;
        }else if(vectorOne.x < 0 && vectorTwo.x < 0 && vectorOne.y > 0 && vectorTwo.y < 0){
            return false;
        }else{
            return true;
        }
    }
    func undoVideoFromRatio(point: CGPoint, rect: CGRect) -> CGPoint{
        return CGPoint(x: ((point.x * rect.width) + rect.minX), y: (rect.maxY - (point.y  *  (rect.height))))
    }
    func processTrajectoryObservations(_ results: [VNTrajectoryObservation]) {
            var timeToDraw = true
            for path in results where path.confidence > 0.90{
                path.detectedPoints.forEach { point in
                    drawPoint(point: point, isSpecial: false)
                }
                print(path.uuid)
                if(isNewPath == true){
                    lastTrajectoryID = path.uuid
                    possibleToPlot.append(path.detectedPoints.last!)
                    timeToDraw = false
                    isNewPath = false
                    runningVector = calculateVector(pointOne: path.detectedPoints.first!, pointTwo: path.detectedPoints.last!)
                }else{
                    if(path.uuid == lastTrajectoryID){
                        let testVector  = calculateVector(pointOne: possibleToPlot.last!, pointTwo: path.detectedPoints.last!)
                        let testing = isVectorChange(vectorOne: runningVector, vectorTwo: testVector)
                        if(!testing){
                        possibleToPlot.append(path.detectedPoints.last!)
                        timeToDraw = false
                        }else{
                            timeToDraw = true
                        }
                    }
                }
                //self.timestamp = Date().currentTimeMillis()
            }
        if(timeToDraw == true && isNewPath == false){
            drawPoint(point: possibleToPlot.last!,isSpecial: true)
        }
    }
    private func drawPoint(point: VNPoint , isSpecial: Bool){
        let finalP = undoVideoFromRatio(point: CGPoint(x: point.x,y: point.y), rect: self.view.frame)
        let final = CGRect(x: finalP.x-5, y: finalP.y-5, width: 7, height: 7)
        if(isSpecial){
            let a1 = DRAW(frame: final)
            view.addSubview(a1)
        }else{
            let a1 = DRAWTwo(frame: final)
            view.addSubview(a1)
        }
        isNewPath = false
        possibleToPlot.removeAll()
        isNewPath = true
        self.mode = 1
        self.timestamp = Date().currentTimeMillis()
    }
   // func setupShot
    
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
    // Set your desired frame rate
    // Set your desired frame rate
    
    
    func setupAVSession() throws {
        // Create device discovery session for a wide angle camera
        let wideAngle = AVCaptureDevice.DeviceType.builtInWideAngleCamera
        
        let device = AVCaptureDevice.default(wideAngle, for: .video, position: .back)!

        // Select a video device, make an input
        //print(videoDevice.formats)
        //print(videoDevice.activeVideoMinFrameDuration)
        //print(videoDevice.activeVideoMinFrameDuration)
        //configureCameraForHighestFrameRate(device: device)
        configureCameraForHighestFrameRate(device: device)
        print(device.activeFormat)
        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        session = AVCaptureSession()
        session.beginConfiguration()

        // We prefer a 1080p video capture but if camera cannot provide it then fall back to highest possible quality
//        if videoDevice.supportsSessionPreset(.hd1920x1080) {
//            session.sessionPreset = .hd1920x1080
//        } else {
//            session.sessionPreset = .high
//        }
        
        // Add a video input
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
        
        setupVideoOutputView(cameraFeedView)
        cameraFeedSession?.startRunning()
    }
}
extension AVCaptureDevice {
    func set(frameRate: Double) {
    guard let range = activeFormat.videoSupportedFrameRateRanges.first,
        range.minFrameRate...range.maxFrameRate ~= frameRate
        else {
            print("Requested FPS is not supported by the device's activeFormat !")
            return
    }

    do { try lockForConfiguration()
        activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
        activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
        unlockForConfiguration()
    } catch {
        print("LockForConfiguration failed with error: \(error.localizedDescription)")
    }
  }
}
class DRAW: UIView {
    //backgroundColor = .white
    override init(frame: CGRect) {
            super.init(frame: frame)
       backgroundColor = .orange
       // layer.cornerRadius = 18
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class DRAWTwo: UIView {
    //backgroundColor = .white
    override init(frame: CGRect) {
            super.init(frame: frame)
       backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DrawRect: UIView {
    //backgroundColor = .white
    override init(frame: CGRect) {
            super.init(frame: frame)
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 9
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


enum AppError: Error {
    case captureSessionSetup(reason: String)
    case createRequestError(reason: String)
    case videoReadingError(reason: String)
    
    static func display(_ error: Error, inViewController viewController: UIViewController) {
        if let appError = error as? AppError {
            appError.displayInViewController(viewController)
        } else {
            print(error)
        }
    }
    func displayInViewController(_ viewController: UIViewController) {
        let title: String?
        let message: String?
        switch self {
        case .captureSessionSetup(let reason):
            title = "AVSession Setup Error"
            message = reason
        case .createRequestError(let reason):
            title = "Error Creating Vision Request"
            message = reason
        case .videoReadingError(let reason):
            title = "Error Reading Recorded Video."
            message = reason
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        viewController.present(alert, animated: true)
        }
    }
    extension Date {
        func currentTimeMillis() -> Int64 {
            return Int64(self.timeIntervalSince1970 * 1000)
        }
    }


