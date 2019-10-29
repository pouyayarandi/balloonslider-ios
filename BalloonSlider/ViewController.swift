//
//  ViewController.swift
//  BalloonSlider
//
//  Created by Pouya on 10/28/19.
//  Copyright © 2019 pouyayarandi. All rights reserved.
//

import UIKit
import GLKit

enum MoveState {
    case equal
    case asc
    case desc
}

class ViewController: UIViewController {
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.setThumbImage(#imageLiteral(resourceName: "thumb-up"), for: .normal)
        balloonView.transform = disappearTransform
    }
    
    override func viewDidLayoutSubviews() {
        thumbView.frame = thumbRect
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
    }
    
    //MARK: Outlets
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var balloonView: UIView!
    @IBOutlet weak var balloonViewLeading: NSLayoutConstraint!
    @IBOutlet weak var numberLabel: UILabel!
    
    //MARK: Variables
    
    var animator: UIDynamicAnimator!
    var behavior: UISnapBehavior!
    
    let touchedThumbBorder: CGFloat = 2
    let releasedThumbBorder: CGFloat = 5
    let timerInterval: TimeInterval = 0.15
    
    var lastRotationDegree: CGFloat = 0
    var lastValue: Float = 0
    var currentValue: Float = 0
    var timer = Timer()
    var lastMoveState = MoveState.equal
    
    var currentMoveState: MoveState {
        if currentValue > lastValue {
            return .asc
        } else if currentValue < lastValue {
            return .desc
        } else {
            return .equal
        }
    }
    
    lazy var thumbView: UIView = {
        let view = UntouchableView()
        view.layer.masksToBounds = true
        view.layer.borderWidth = releasedThumbBorder
        view.layer.borderColor = #colorLiteral(red: 0.3411764706, green: 0.1529411765, blue: 0.9176470588, alpha: 1)
        view.backgroundColor = .white
        self.view.addSubview(view)
        return view
    }()
    
    var thumbRect: CGRect {
        return thumbRect(with: slider.value)
    }
    
    var lastThumbRect: CGRect {
        return thumbRect(with: lastValue)
    }
    
    var snapPoint: CGPoint {
        return CGPoint(
            x: thumbRect.origin.x,
            y: slider.frame.minY - balloonView.frame.height - 100
        )
    }
    
    var disappearTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 0.000001, y: 0.000001)
            .translatedBy(x: 0, y: 1000000)
    }
    
    //MARK: Functions
    
    func thumbRect(with value: Float) -> CGRect {
        let rect = slider.thumbRect(
            forBounds: slider.bounds,
            trackRect: slider.trackRect(forBounds: slider.bounds),
            value: value
        )
        return CGRect(
            x: rect.origin.x + slider.frame.minX,
            y: slider.frame.minY,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    func toggleThumbAnimation(expand: Bool) {
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.duration = 0.1
        anim.fromValue = expand ? 1 : 1.2
        anim.toValue = expand ? 1.2 : 1
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        thumbView.layer.removeAllAnimations()
        thumbView.layer.add(anim, forKey: "thumbScale")
    }
    
    func startMovementTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: { _ in
            self.lastValue = self.currentValue
            self.currentValue = self.slider.value
            UIView.animate(withDuration: 0.1, animations: {
                self.balloonViewLeading.constant = self.lastThumbRect.midX - self.slider.frame.minX
                self.view.layoutSubviews()
            })
            self.rotateBalloon()
            self.lastMoveState = self.currentMoveState
        })
    }
    
    func rotateBalloon() {
        var degree: CGFloat =  0
        var mult: CGFloat = 1
        
        if currentMoveState == .asc {
            mult = -1
        }
        
        if currentMoveState == .equal {
            mult = 0
        }
        
        if abs(balloonView.center.x - thumbView.center.x) > 5 {
            degree = mult * CGFloat(GLKMathDegreesToRadians(20))
        }
        
        let scale = 1 + CGFloat(slider.value - 0.5) / 10
        
        UIView.animate(withDuration: 0.2) {
            self.balloonView.transform = CGAffineTransform(rotationAngle: degree)
                .scaledBy(x: scale, y: scale)
        }
    }
    
    //MARK: Actions
    
    @IBAction func sliderTouchDown(_ sender: UISlider) {
        startMovementTimer()
        toggleThumbAnimation(expand: true)
        UIView.animate(withDuration: 0.1) {
            self.thumbView.layer.borderWidth = self.touchedThumbBorder
            self.balloonView.transform = .identity
        }
    }

    @IBAction func sliderTouchUp(_ sender: UISlider) {
        timer.invalidate()
        toggleThumbAnimation(expand: false)
        UIView.animate(withDuration: 0.1) {
            self.thumbView.layer.borderWidth = self.releasedThumbBorder
            self.balloonView.transform = self.disappearTransform
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        numberLabel.text = String(Int(slider.value * 100))
    }
}

/// A subclass of UIView which pass touch to the bottom layer
class UntouchableView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
