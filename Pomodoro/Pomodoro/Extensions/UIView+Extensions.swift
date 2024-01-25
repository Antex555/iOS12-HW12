//
//  View+Extensions.swift
//  Pomodoro
//
//  Created by Anton Popeka on 23/01/24.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
}

extension UIView {
    func addSubLayers(_ layers: [CALayer]) {
        layers.forEach { self.layer.addSublayer($0) }
    }
}

extension Int {
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180
    }
}
