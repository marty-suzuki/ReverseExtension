//
//  MessageModel.swift
//  ReverseExtensionSample
//
//  Created by marty-suzuki on 2017/03/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

struct MessageModel {
    private struct Const {
        static let imageNames: [String] = ["marty1", "marty2", "doc1", "doc2"]
        static let messags: [String] = [
            "You've gotta come back with me!",
            "Where?",
            "Back to the future!",
            "Great scott!",
            "If you put your mind to it, you can accomplish anything.",
            "I need a nuclear reaction to generate the 1.21 gigawatts of electricity I need."
        ]
        static let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
    }
    
    let imageName: String
    let message: String
    let time: String
}

extension MessageModel {

    init() {
        imageName = Const.imageNames[Int(arc4random_uniform(UInt32(Const.imageNames.count)))]
        message = Const.messags[Int(arc4random_uniform(UInt32(Const.messags.count)))]
        time = Const.formatter.string(from: Date())
    }
}
