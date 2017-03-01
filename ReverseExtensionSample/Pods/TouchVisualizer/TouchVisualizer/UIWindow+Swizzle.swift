//
//  UIWindow+Swizzle.swift
//  TouchVisualizer
//

import UIKit

fileprivate var isSwizzled = false

@available(iOS 8.0, *)
extension UIWindow {
	
	public func swizzle() {
		if (isSwizzled) {
			return
		}
		
		let sendEvent = class_getInstanceMethod(object_getClass(self), #selector(UIApplication.sendEvent(_:)))
		let swizzledSendEvent = class_getInstanceMethod(object_getClass(self), #selector(UIWindow.swizzledSendEvent(_:)))
		method_exchangeImplementations(sendEvent, swizzledSendEvent)
		
		isSwizzled = true
	}
	
	public func swizzledSendEvent(_ event: UIEvent) {
		Visualizer.sharedInstance.handleEvent(event)
		swizzledSendEvent(event)
	}
}
