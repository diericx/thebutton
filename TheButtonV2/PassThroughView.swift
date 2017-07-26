//
//  CoinsViewController.swift
//  TheButtonV2
//
//  Created by Zac Holland on 7/24/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import Foundation
import UIKit

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
