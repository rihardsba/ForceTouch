//
//  ForceTouchActionVC.swift
//  Gensler
//
//  Created by Rihards Baumanis
//  Copyright © 2017 Chili. All rights reserved.
//

import UIKit

final class ForceTouchActionVC: UIViewController {

    let snapshot: UIView?

    private let buttonSize = CGSize(width: 40, height: 40)
    private let span: CGFloat = 43
    private let initialTouch: UITouch
    private var initialTouchPoint: CGPoint!

    var recognizer: ForceTouchGestureRecognizer?

    private lazy var shareButton: UIButton = {

        var frame = CGRect.zero
        frame.size = self.buttonSize

        let shareButton = UIButton(type: .custom)
        shareButton.frame = frame
        shareButton.backgroundColor = .blue
        shareButton.alpha = 0

        self.view.addSubview(shareButton)
        return shareButton
    }()

    private lazy var favoriteButton: UIButton = {
        var frame = CGRect.zero
        frame.size = self.buttonSize

        let favoriteButton = UIButton(type: .custom)
        favoriteButton.frame = frame
        favoriteButton.backgroundColor = .blue

        favoriteButton.alpha = 0

        self.view.addSubview(favoriteButton)
        return favoriteButton
    }()

    init(snapshot: UIView?, initialTouch: UITouch, forceRecognizer: ForceTouchGestureRecognizer) {
        self.recognizer = forceRecognizer
        self.snapshot = snapshot
        self.initialTouch = initialTouch
        super.init(nibName: nil, bundle: nil)

        setupForceRecognizer(forceRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapHostView = UIView(frame: view.bounds)
        view.addSubview(tapHostView)

        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(onTap(_:)))
        tapRecognizer.cancelsTouchesInView = false
        tapHostView.addGestureRecognizer(tapRecognizer)

        view.backgroundColor = .white

        if let snapshot = snapshot {
            view.addSubview(snapshot)
        }

        var point = initialTouch.location(in: view)
        point.y -= 44
        initialTouchPoint = point
    }

    func handle(force: CGFloat) {
        let size = CGSize(width: 40, height: 40)

        var frame = CGRect(origin: .zero, size: size)

        frame.center = self.initialTouchPoint

        let span: CGFloat = 60

        let distance = span + size.width / 2

        let vMult: CGFloat = self.initialTouchPoint.y < distance ? 1 : -1
        let hMult: CGFloat = self.initialTouchPoint.x < distance ? 1 : -1

        var shareFrame = frame
        shareFrame.center.y += distance * force * vMult

        var favFrame = frame
        favFrame.center.y += distance * force * sin(.pi / 4) * vMult
        favFrame.center.x += distance * force * cos(.pi / 4) * hMult

        self.shareButton.frame = shareFrame
        self.favoriteButton.frame = favFrame

        self.shareButton.alpha = force
        self.favoriteButton.alpha = force

        self.view.backgroundColor = UIColor(white: 1, alpha: force * 0.8)
    }

    private func setupForceRecognizer(_ forceRecognizer: ForceTouchGestureRecognizer) {

        forceRecognizer.forceUpdate = { [weak self] force in
            self?.handle(force: force)
        }

        forceRecognizer.fixed = {
            forceRecognizer.forceUpdate = nil
        }

        forceRecognizer.ended = { [weak self] in
            forceRecognizer.forceUpdate = nil

            UIView.animate(withDuration: 0.2, animations: {
                self?.handle(force: 0.0)
            }) { [weak self] (_) in
                self?.dismiss(animated: false, completion: nil)
            }
        }
    }

    internal func animatedDismiss() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.handle(force: 0.1)
        }) { [weak self] (_) in
            self?.dismiss(animated: false, completion: nil)
        }
    }

    @objc private func onTap(_ sender: UITapGestureRecognizer) {
        animatedDismiss()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.dismiss(animated: false, completion: nil)
    }
}

extension CGRect {
    var center: CGPoint {
        get {
            return CGPoint(x: origin.x + midX, y: origin.y - midY)
        }
        set {
            origin = CGPoint(x: newValue.x - midX, y: newValue.y + midY)
        }
    }
}

extension CGSize {
    init(_ w: CGFloat, _ h: CGFloat) {
        self.init(width: w, height: h)
    }
}
