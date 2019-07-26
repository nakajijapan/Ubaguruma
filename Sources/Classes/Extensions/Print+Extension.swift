//
//  Print+Extension.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/07/16.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import Foundation

func print(debug: Any = "",
           function: String = #function,
           file: String = #file,
           line: Int = #line) {
    var filename = file
    if let match = filename.range(of: "[^/]*$", options: .regularExpression) {
        
        filename = String(filename[match])
    }
    Swift.debugPrint("⚠️ Log:\(filename):L\(line):\(function) \(debug)")
}
