//
//  KeyValueObserver.swift
//  Pods
//
//  Created by marty-suzuki on 2017/04/03.
//
//

import Foundation

final class KeyValueObserver: NSObject {
    private weak var tareget: NSObject?
    private let keyPath: String
    
    var didChange: ((Any?, [NSKeyValueChangeKey : Any]?) -> ())?
    
    init(tareget: NSObject, forKeyPath keyPath: String) {
        self.keyPath = keyPath
        self.tareget = tareget
        super.init()
        tareget.addObserver(self, forKeyPath: keyPath, options: [.new, .old], context: nil)
    }
    
    deinit {
        try? ExceptionHandler.catchException {
            tareget?.removeObserver(self, forKeyPath: keyPath)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case (self.keyPath)?:
            DispatchQueue.global().async { [weak self] in
                self?.didChange?(object, change)
            }
        default:
            break
        }
    }
}
