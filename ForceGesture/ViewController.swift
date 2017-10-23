//
//  ViewController.swift
//  ForceGesture
//
//  Created by Rihards Baumanis
//  Copyright © 2017 Chili. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var forceGestureRecognizer: ForceTouchGestureRecognizer?

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribeForForceRecognizer()

        // Do any additional setup after loading the view, typically from a nib.
    }

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        cell.backgroundColor = .black
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension ViewController: ForceActionPresentable {
    var forceTouchView: UIView {
        return collectionView
    }

    func snapshot(at point: CGPoint) -> UIView? {
        guard let view = viewAtPoint(point) else { return nil }

        let imageView = UIImageView(frame: view.frame)
        imageView.image = view.snapshot()
        return imageView
    }

    private func viewAtPoint(_ point: CGPoint) -> UIView? {
        guard collectionView.cellAtPoint(point) != nil else { return nil }
        return collectionView.viewAtPoint(point)
    }
}

extension UICollectionView {
    func cellAtPoint(_ point: CGPoint) -> UICollectionViewCell? {
        let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        guard let attributes = collectionViewLayout.layoutAttributesForElements(in: rect)?.first else {
            return nil
        }
        return self.cellForItem(at: attributes.indexPath)
    }

    func viewAtPoint(_ point: CGPoint) -> UIView? {
        guard let attributes = collectionViewLayout.layoutAttributes(at: point) else { return nil }

        switch attributes.representedElementCategory {
        case .cell:
            return cellForItem(at: attributes.indexPath)
        case .supplementaryView:
            return supplementaryView(forElementKind: attributes.representedElementKind!, at: attributes.indexPath)
        default:
            return nil
        }
    }
}

extension UICollectionViewLayout {
    func layoutAttributes(at point: CGPoint) -> UICollectionViewLayoutAttributes? {
        let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        return layoutAttributesForElements(in: rect)?.first
    }
}

extension UIView {

    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
