//
//  Ubaguruma.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/06/03.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import Foundation

public protocol UbagurumaCompatible {
    var currentViewController: UIViewController? { get }
}
public extension UbagurumaCompatible where Self: UIViewController {
}
extension UINavigationController: UbagurumaCompatible { }
extension UITabBarController: UbagurumaCompatible { }
