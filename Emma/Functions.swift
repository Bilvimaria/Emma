//
//  Functions.swift
//  Emma
//
//  Created by Bilvi Maria Joseph on 2019-03-21.
//  Copyright © 2019 Bilvi Maria Joseph. All rights reserved.
//

import Foundation
let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory,in: .userDomainMask)
        return paths[0]
}()

