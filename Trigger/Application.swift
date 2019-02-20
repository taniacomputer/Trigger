//
//  Application.swift
//  Trigger
//
//  Created by Tania  on 28/10/2016.
//  Copyright © 2016 TaniaComputer. All rights reserved.
//

import Foundation
import Cocoa

class Application: NSApplication {
	override func sendEvent(_ theEvent: NSEvent) {
		print(theEvent.type)
		if theEvent.type == .systemDefined && theEvent.subtype.rawValue == 8 {
			_ = ((theEvent.data1 & 0xFFFF0000) >> 16)
			let keyFlags = (theEvent.data1 & 0x0000FFFF)
			// Get the key state. 0xA is KeyDown, OxB is KeyUp
			_ = (((keyFlags & 0xFF00) >> 8)) == 0xA
			_ = (keyFlags & 0x1)
			//mediaKeyEvent(key: Int32(keyCode), state: keyState, keyRepeat: Bool(keyRepeat))
		}
		super.sendEvent(theEvent)
		//note that without the above line the app doesn't respond to clicks or any keyboard events
	}
	
	func mediaKeyEvent(key: Int32, state: Bool, keyRepeat: Bool) {
		print(key)
		// Only send events on KeyDown. Without this check, these events will happen twice
		if (state) {
			switch(key) {
			case NX_KEYTYPE_LAUNCH_PANEL:
				//F8 pressed
				break
			case NX_KEYTYPE_FAST:
				//F9 pressed
				break
			case NX_KEYTYPE_REWIND:
				//F7 pressed
				break
			default:
				print(key)
				break
			}
		}
	}
}
