//
//  ForceActionPresentable.swift
//  Gensler
//
//  Created by Rihards Baumanis
//  Copyright © 2017 Chili. All rights reserved.
//

import UIKit

protocol ForceActionPresentable: class {
    var forceGestureRecognizer: ForceTouchGestureRecognizer? { get set }
    var forceTouchView: UIView { get }
    func snapshot(at point: CGPoint) -> UIView?
}

extension ForceActionPresentable where Self: UIViewController {

    func subscribeForForceRecognizer() {
        let forceTouchView = self.forceTouchView

        let canHandleForceTouch = forceTouchView.traitCollection.forceTouchCapability == .available
        let threshold: CGFloat = canHandleForceTouch ? 0.3 : 1
        let type: RecognizerType = canHandleForceTouch ? .forceTouch : .longPress
        let forceRecognizer = ForceTouchGestureRecognizer(threshold: threshold, type: type)
        self.forceGestureRecognizer = forceRecognizer

        forceTouchView.addGestureRecognizer(forceRecognizer)

        if let delegate = self as? UIGestureRecognizerDelegate {
            forceRecognizer.delegate = delegate
        }

        forceRecognizer.began = { [weak self] touch in

            let location = touch.location(in: forceTouchView)

            guard let strongSelf = self,
                let snapshot = strongSelf.snapshot(at: location) else {
                    return
            }

            let actionVC = ForceTouchActionVC(snapshot: snapshot,
                                              initialTouch: touch,
                                              forceRecognizer: forceRecognizer)

            actionVC.view.backgroundColor = UIColor(white: 1, alpha: 0)
            snapshot.frame = forceTouchView.convert(snapshot.frame, to: actionVC.view)

            actionVC.modalPresentationStyle = .overCurrentContext
            self?.present(actionVC, animated: false, completion: nil)
        }
    }
}
