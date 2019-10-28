//
//  ViewController.swift
//  BalloonSlider
//
//  Created by Pouya on 10/28/19.
//  Copyright © 2019 pouyayarandi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let touchedThumbBorder: CGFloat = 2
    let releasedThumbBorder: CGFloat = 5
    
    var timer = Timer()
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var balloonView: UIView!
    @IBOutlet weak var balloonViewLeading: NSLayoutConstraint!
    
    lazy var thumbView: UIView = {
        let view = UntouchableView()
        view.layer.masksToBounds = true
        view.layer.borderWidth = releasedThumbBorder
        view.layer.borderColor = #colorLiteral(red: 0.3411764706, green: 0.1529411765, blue: 0.9176470588, alpha: 1)
        view.backgroundColor = .white
        self.view.addSubview(view)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.setThumbImage(#imageLiteral(resourceName: "thumb-up"), for: .normal)
        balloonView.transform = disappearTransform
    }
    
    override func viewDidLayoutSubviews() {
        thumbView.frame = thumbRect
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
    }
    
    var thumbRect: CGRect {
        let rect = slider.thumbRect(
            forBounds: slider.bounds,
            trackRect: slider.trackRect(forBounds: slider.bounds),
            value: slider.value
        )
        return CGRect(
            x: rect.origin.x + slider.frame.minX,
            y: slider.frame.minY,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    func toggleThumAnimation(expand: Bool) {
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.duration = 0.1
        anim.fromValue = expand ? 1 : 1.2
        anim.toValue = expand ? 1.2 : 1
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        thumbView.layer.removeAllAnimations()
        thumbView.layer.add(anim, forKey: "thumbScale")
    }
    
    var disappearTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 0.000001, y: 0.000001)
            .translatedBy(x: 0, y: 1000)
    }
    
    @IBAction func sliderTouchDown(_ sender: UISlider) {
        toggleThumAnimation(expand: true)
        UIView.animate(withDuration: 0.1) {
            self.thumbView.layer.borderWidth = self.touchedThumbBorder
            self.balloonView.transform = .identity
        }
    }

    @IBAction func sliderTouchUp(_ sender: UISlider) {
        toggleThumAnimation(expand: false)
        UIView.animate(withDuration: 0.1) {
            self.thumbView.layer.borderWidth = self.releasedThumbBorder
            self.balloonView.transform = self.disappearTransform
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        balloonViewLeading.constant = thumbRect.midX - slider.frame.minX - 2
    }
}

class UntouchableView: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
}
