//
//  ForceTouchGestureRecognizer.swift
//  Gensler
//
//  Created by Rihards Baumanis
//  Copyright © 2017 Chili. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import AudioToolbox

enum RecognizerType {
    case forceTouch
    case longPress
}

class ForceTouchGestureRecognizer: UIGestureRecognizer {

    enum RecognizerState {
        case started
        case fixed
        case ended
    }

    private(set) var gestureState: RecognizerState = .ended {
        didSet {
            guard gestureState != oldValue else { return }
            switch gestureState {
            case .fixed:
                fixed?()
            case .started:
                began?(lastTouch!)

                cancelsTouchesInView = true
            case .ended:

                startTimer?.invalidate()
                animateTimer?.invalidate()

                forceSimulator = 0.1
                cancelsTouchesInView = false
                if oldValue != .fixed {
                    ended?()
                }
            }
        }
    }

    private var lastTouch: UITouch?

    var began: ((UITouch) -> Void)?
    var fixed: (() -> Void)?
    var forceUpdate: ((CGFloat) -> Void)?
    var ended: (() -> Void)?

    var startTimer: Timer?
    var animateTimer: Timer?

    var forceSimulator: CGFloat = 0.1
    let threshold: CGFloat
    let type: RecognizerType

    init(threshold: CGFloat, type: RecognizerType) {
        self.threshold = threshold
        self.type = type

        super.init(target: nil, action: nil)

        cancelsTouchesInView = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        changeState(.began, touches: touches, event: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        changeState(.changed, touches: touches, event: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        changeState(.ended, touches: touches, event: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        changeState(.cancelled, touches: touches, event: event)
    }

    override func reset() {
        super.reset()
        gestureState = .ended
    }

    @objc func animateView() {
        forceUpdate?(forceSimulator)
        forceSimulator += 0.05
        if gestureState == .started && forceSimulator >= threshold {
            forceUpdate?(1)
            gestureState = .fixed
            animateTimer?.invalidate()
        }
    }

    @objc func setStart() {
        startTimer?.invalidate()
        gestureState = .started
        animateTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(animateView), userInfo: nil, repeats: true)
    }

    private func changeState(_ state: UIGestureRecognizerState, touches: Set<UITouch>, event: UIEvent) {

        guard let touch = touches.first else { return }
        let force = touch.force / touch.maximumPossibleForce

        lastTouch = touch

        switch state {
        case .began:
            if type == .longPress {
                startTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(setStart), userInfo: nil, repeats: false)
            }
        case .changed:
            if type == .longPress || gestureState == .fixed {
                // do nothing if we are in fixed state
                break
            }

            // do nothing if we are in ended state below threshold
            if gestureState == .ended && force < threshold {
                break
            }

            // promote to started state if above threshold
            if gestureState == .ended && force >= threshold {
                gestureState = .started
            }

            forceUpdate?(force)

            // lastly, if we reached force == 1, change to fixed state
            if gestureState == .started && force == 1 {
                gestureState = .fixed
            }

        case .ended, .cancelled:
            gestureState = .ended

            startTimer?.invalidate()
            animateTimer?.invalidate()
        default:
            break
        }

        self.state = state
    }
}
