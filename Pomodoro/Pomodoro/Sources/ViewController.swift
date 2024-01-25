//
//  ViewController.swift
//  Pomodoro
//
//  Created by Anton Popeka on 22/01/24.
//

import UIKit

class ViewController: UIViewController, CAAnimationDelegate {

    let animation = CABasicAnimation(keyPath: "strokeEnd")

    var timer = Timer()
    var isTimerStarted = false
    var isAnimationStarted = false
    var time = 25
    
    // MARK: - Lifecycle
    
    override func loadView() {
       
        let screenSize = UIScreen.main.bounds.size
        let myView = UIView(frame: CGRect(x: 0, 
                                          y: 0,
                                          width: screenSize.width,
                                          height: screenSize.height))
        view = myView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarhy()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - UI
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "25:00"
        label.textColor = .red
        label.font = UIFont(name: "Arial", size: 40)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var playAndStopButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(.playBtn, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backProgressLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX, 
                                                     y: view.frame.midY),
                                  radius: 100,
                                  startAngle: -90.degreesToRadians,
                                  endAngle: 270.degreesToRadians,
                                  clockwise: true).cgPath
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 7
        return shape
    }()
    
    private lazy var foreProgressLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX, 
                                                     y: view.frame.midY),
                                  radius: 100,
                                  startAngle: -90.degreesToRadians,
                                  endAngle: 270.degreesToRadians,
                                  clockwise: true).cgPath
        shape.strokeColor = UIColor.red.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 5
        return shape
    }()
    
    // MARK: - Setup
    
    private func setupView() {
        
    }
    
    private func setupHierarhy() {
        view.addSubviews([
            timeLabel,
            playAndStopButton
        ])
        
        view.addSubLayers([
            backProgressLayer
        ])

    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            playAndStopButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
            playAndStopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Actions
    
    private func startResumeAnimation() {
        if !isAnimationStarted {
            startAnimation()
        } else {
            resumeAnimation()
        }
    }
    
    private func startAnimation() {
        resetAnimation()
        foreProgressLayer.strokeEnd = 0.0
        animation.keyPath = "strokeEnd"
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 25
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        foreProgressLayer.add(animation, forKey: "strokeEnd")
        isAnimationStarted = true
    }
    
    private func resetAnimation() {
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        isAnimationStarted = false
    }
    
    private func pauseAnimation() {
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        foreProgressLayer.speed = 0.0
        foreProgressLayer.timeOffset = pausedTime
    }
    
    private func resumeAnimation() {
        let pausedTime = foreProgressLayer.timeOffset
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        let timeSincePaused = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        foreProgressLayer.beginTime = timeSincePaused
    }
    
    private func stopAnimation() {
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        foreProgressLayer.removeAllAnimations()
        isAnimationStarted = false
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, 
                                     target: self,
                                     selector: (#selector(updateTimer)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc
    private func updateTimer() {
        if time < 1 {
            playAndStopButton.setImage(.playBtn, for: .normal)
            timer.invalidate()
            time = 25
            isTimerStarted = false
            timeLabel.text = "25:00"
        } else {
            time -= 1
            timeLabel.text = formatTimer()
        }
    }
    
    private func formatTimer() -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    

    @objc 
    private func playButtonTapped() {
        if !isTimerStarted {
            view.layer.addSublayer(foreProgressLayer)
            startResumeAnimation()
            startTimer()
            isTimerStarted = true
            playAndStopButton.setImage(.pauseBtn, for: .normal)
        } else {
            pauseAnimation()
            timer.invalidate()
            isTimerStarted = false
            playAndStopButton.setImage(.playBtn, for: .normal)
        }
    }
    
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }
}

