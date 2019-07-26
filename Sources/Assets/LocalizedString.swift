//
//  LocalizedString.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/07/21.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import Foundation

public struct L10n {
    static func localize(_ key: String) -> String {
        guard let bundle = Bundle(identifier: "net.nakajijapan.Ubaguruma") else { return "" }
        return NSLocalizedString(key, tableName: nil, bundle: bundle, comment: "")
    }
}
