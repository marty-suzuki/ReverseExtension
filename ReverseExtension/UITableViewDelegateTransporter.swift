//
//  UITableViewDelegateTransporter.swift
//  ReverseExtension
//
//  Created by marty-suzuki on 2017/03/01.
//
//

import UIKit

class UITableViewDelegateTransporter: DelegateTransporter, UITableViewDelegate {
    @nonobjc convenience init(delegates: [UITableViewDelegate]) {
        self.init(__delegates: delegates)
    }
}
