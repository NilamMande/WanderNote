//
//  CustomButton.swift
//  WanderNote
//
//  Created by Nilam on 4/8/18.
//  Copyright © 2018 Wander. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
        }
    }
}

