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
    var time = 10
    
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
        setupHierarhy()
        setupLayout()
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
        button.setImage(.playBtnRed, for: .normal)
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
        shape.strokeColor = UIColor.gray.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 1
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
        shape.lineWidth = 2
        return shape
    }()
    
    // MARK: - Setup
    
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
        animation.duration = CFTimeInterval(time)
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
//        let pausedTime = foreProgressLayer.timeOffset
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
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
            if timeLabel.textColor == .green {
                playAndStopButton.setImage(.playBtnRed, for: .normal)
                timer.invalidate()
                time = 10
                foreProgressLayer.strokeColor = UIColor.red.cgColor
                isTimerStarted = false
                timeLabel.text = "25:00"
                timeLabel.textColor = .red
            } else {
                playAndStopButton.setImage(.playBtnGreen, for: .normal)
                timer.invalidate()
                time = 5
                foreProgressLayer.strokeColor = UIColor.green.cgColor
                isTimerStarted = false
                timeLabel.text = "5:00"
                timeLabel.textColor = .green
            }
            
        } else {
            time -= 1
            print("1")
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
            if foreProgressLayer.strokeColor == UIColor.red.cgColor {
                playAndStopButton.setImage(.pauseBtnRed , for: .normal)
            } else {
                playAndStopButton.setImage(.pauseBtnGreen, for: .normal)
                }
        } else {
            pauseAnimation()
            timer.invalidate()
            isTimerStarted = false
            if foreProgressLayer.strokeColor == UIColor.red.cgColor {
                playAndStopButton.setImage(.playBtnRed, for: .normal)
            } else {
                playAndStopButton.setImage(.playBtnGreen, for: .normal)
            }
        }
    }
    
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }
}

