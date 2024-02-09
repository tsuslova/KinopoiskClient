//
//  UIApplicationHelpers.swift
//  KinopoiskClient
//
//  Created by Toto on 09.02.2024.
//

import UIKit

extension UIApplication {
    var statusBarHeight: CGFloat {
        get {
            self.connectedScenes
                .filter {$0.activationState == .foregroundActive }
                .map {$0 as? UIWindowScene }
                .compactMap { $0 }
                .first?.windows
                .filter({ $0.isKeyWindow }).first?
                .windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
    }
}
