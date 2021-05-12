//
//  UITableViewDelegateProxy.swift
//  ReverseExtension
//
//  Created by marty-suzuki on 2017/03/01.
//
//

import UIKit

final class UITableViewDelegateProxy: DelegateProxyBase, UITableViewDelegate {
    convenience init(delegates: [UITableViewDelegate]) {
        self.init(__delegates: delegates)
    }
}
