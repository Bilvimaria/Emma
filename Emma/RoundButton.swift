//
//  RoundButton.swift
//  Emma
//
//  Created by Bilvi Maria Joseph on 2019-03-07.
//  Copyright © 2019 Bilvi Maria Joseph. All rights reserved.
//

import UIKit
@IBDesignable


class RoundButton: UIButton {

    @IBInspectable var roundButton:Bool =  false{
        didSet{
            if roundButton{
                layer.cornerRadius = frame.height/2
            }
        }
    }
    override func prepareForInterfaceBuilder() {
        if roundButton{
            layer.cornerRadius = frame.height/2
        }
    }
}
