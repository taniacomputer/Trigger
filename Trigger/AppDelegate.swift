//
//  AppDelegate.swift
//  Trigger
//
//  Created by Tania on 28/10/2016.
//  Copyright © 2016 TaniaComputer. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
	
  var commandViews = [CommandView]()
	
    let widthMax = Int((NSScreen.main?.frame.width)!)
	let heightMax = Int((NSScreen.main?.frame.height)!)
	let heightMin = 64
	let widthMin = 192
	let marginWidth = 0
	var width = 360
	var height = 320
	var title = ""
	var showTitleBar = false
	var logPath: String? = nil

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
	func isVerb(str:String) -> Bool {
		let verbs = ["about",
			"bind",
			"bless",
			"checkJSSConnection",
			"createAccount",
			"createConf",
			"createHooks",
			"createSetupDone",
			"createStartupItem",
			"deleteAccount",
			"deletePrinter",
			"deleteSetupDone",
			"displayMessage",
			"enablePermissions",
			"enroll",
			"fixByHostFiles",
			"fixDocks",
			"fixPermissions",
			"flushCaches",
			"flushPolicyHistory",
			"getARDFields",
			"getComputerName",
			"heal",
			"help",
			"install",
			"installAllCached",
			"listUsers",
			"log",
			"manage",
			"mapPrinter",
			"mcx",
			"modifyDock",
			"mount",
			"notify",
			"policy",
			"reboot",
			"recon",
			"removeFramework",
			"removeSWUSettings",
            "resetPassword",
            "runScript",
            "runSoftwareUpdate",
            "setARDFields",
            "setComputerName",
            "setHomePage",
            "setOFP",
            "startSSH",
            "uninstall",
            "unmountServer",
            "updatePrebindings",
            "version",
			"sleep",
			"wait"
		]
		if verbs.contains(str) {
			return true
		} else {
			return false
		}
	}
    
	func displayManPage() {
		let singleIndent="\t\t"
		let doubleIndent="\t\t\t\t"
        print("Usage:")
        print("Trigger.app/Contents/MacOS/Trigger WEBVIEW_1 COMMAND_1 WEBVIEW_2 COMMAND_2 … [OPTIONS]")
        print("Trigger displays a web view while simultaneously executing a command. Once the command finishes executing Trigger moves on to the next web view/command pair.")
        print("")
        print("WEBVIEW")
        print("The local HTML file or HTML string to display")
        print("-f, –file <path to file>")
        print("OR")
        print("-html, –html <HTML string>")
        print("")
        print("COMMAND")
        print("The command to execute. Command can be a shell command or a jamf binary command.")
        print("")
        print("Example shell commands:")
        print("\"sleep 5\"")
        print("\"/tmp/a_script.sh\"")
        print("\"/usr/sbin/installer -package ‘/tmp/CocoaDialog v2.1.1.pkg’ -target /\"")
        print("Note the single quotes to wrap around the filename with spaces.")
        print("")
        print("Accepted jamf commands:")
        print("All jamf verbs, although be warned that Trigger has only been tested with jamf binary versions 9.61 – 9.97, so far.")
        print("Note: Trigger assumes that the binary is in /usr/local/bin/jamf. Specify fullpath if you relocated the binary.")
        print("")
        print("Trigger needs to be run as root to run jamf commands.")
        print("")
        print("Example jamf commands:")
        print("\"policy -trigger ‘microsoft office'\"")
        print("\"policy -trigger vlc\"")
        print("\"recon\"")
        print("")
        print("There is one special Trigger commands: wait")
        print("wait displays the webView until a particular link on the presented HTML.")
        print("")
        print("Trigger.app/Contents/MacOS/Trigger WEBVIEW wait")
        print("")
        print("What occurs once the link is clicked depends on the url:")
        print("– A link to “next”, eg. <a href=”http://next”>NEXT</a>, makes Trigger proceed to the next web view/command pair.")
        print("– A link to “formParse”, eg. <a href=”http://formParse”>Submit</a>, will inspect any form values and return the results to stdout. before proceeding to the next web view/command pair.")
        print("– A link to “quit”, eg. <a href=”http://quit”>Done</a>, terminates Trigger.")
        print("Be sure to add http:// in the link URL (required by macOS 10.12.4+)")
        print("")
        print("COMMAND,NAME")
        print("If an output file is specified (see ‘-o, –output’ option below), all named commands have their stdout and success status written to this file.")
        print("A command is named by appending a comma followed by the name in quotations.")
        print("eg. \"policy -trigger mcafee”,”McAfee Security Agent\"")
        print("")
        print("OPTIONS")
        print("-t,–title <title>")
        print("Title of the Trigger window.")
        print("By default there is no title.")
        print("")
        print("-h, –height <window height>")
        print("Height, in pixels, of content window.")
        print("Default height is 320px.")
        print("")
        print("-w, –width <window width>")
        print("Width, in pixels, of content window.")
        print("Must be within the minimum and maximum width of the content window.")
        print("Default width is 360px.")
        print("")
        print("–noTitleBar, –notitlebar")
        print("Hides the titlebar.")
        print("")
        print("–fullscreen")
        print("Puts the Trigger webView in fullscreen mode, and disables process switching, the dock, the apple menu, the menubar, and although the expose funtion key still works the user will be unable to switch to another application. Shift-command-Q for logout will work.")
        print("There is no title bar when in fullscreen mode.")
        print("")
        print("–blurry")
        print("Applies a blurry overlay to the screen, behind the webView.")
        print("Cannot be used in conjunction with –fullscreen.")
        print("")
        print("-o, –output <output file fullpath>")
        print("Creates an output html file. All named commands have their results written to it.")
        
		NSApplication.shared.terminate(self)
	}
	
	func error(err:String) {
		print("There is an error in your syntax.")
		print("Error: \(err)")
		print("Use --help for more information.")
		//displayManPage()
		NSApplication.shared.terminate(self)
	}
	
	func validateAndReturnLocalWebFile(filePath:NSString) -> LocalWebFile {
		var file:LocalWebFile = (nil, nil)
		
		let fileManager = FileManager()
		let fileExists = fileManager.fileExists(atPath: filePath as String)
		if fileExists {
        let ext = filePath.pathExtension
				if ext != "html" {
					error(err: "file is not a html file.")
				} else {
					
					let filename = filePath.lastPathComponent
					let range = filePath.range(of: filename)
					
					file.0 = filePath as String //Fullpath
					file.1 = filePath.substring(to: range.location) //Directory
					
					if file.1?.count == 0 {
						let cwd = FileManager.default.currentDirectoryPath
						file.1 = "\(cwd)/"
						file.0 = file.1!.appending(file.0!)
					}
				}
			
		} else {
			error(err: "the html file you have specified does not exist: \(filePath)")
		}
		return file
	}
	
	func getCommandView(isFile: Bool, jamfVerbAndName: String) -> CommandView {
		let whichJamf = "/usr/local/bin/jamf"
		let whichSleep = "/bin/sleep"
		let whichWait = "/usr/bin/wait"
		
		var taskName:String? = nil
		var jamfTask:String? = nil
 
        // Check if command name is specified
        // eg. "policy -trigger mcafee","McAfee Security Agent"
		if jamfVerbAndName.contains(",") {
            let jamfVerbAndNameSplit = jamfVerbAndName.split(separator: ",").map(String.init)
            
            jamfTask = jamfVerbAndNameSplit[0]
			taskName = jamfVerbAndNameSplit[1]
		} else {
			jamfTask = jamfVerbAndName
			taskName = nil
		}
		
		jamfTask = jamfTask?.replacingOccurrences(of: whichJamf, with: "")
		jamfTask = jamfTask?.replacingOccurrences(of: whichSleep, with: "sleep")
		jamfTask = jamfTask?.replacingOccurrences(of: whichWait, with: "wait")
		
        // Parse the command arguments
		let arguments:[String] = jamfTask!.split(separator: " ").map(String.init)
		var inSingleQuote = false
		var totalQuotes = 0
		var newArguments:[String] = [String]()
		var task:[String] = [String]()
			
        // Check for correct number of quotation marks
		for word in arguments {
		
			var newWord = word
				
			if newWord.first! == "\'" {
					
				if inSingleQuote == false {
						newWord.removeFirst()
						inSingleQuote = true
						totalQuotes += 1
				} else {
						error(err: "Quotes used incorrectly.")
				}
					
				if newWord.last == "\'" {
						newWord.removeLast()
						inSingleQuote = false
						totalQuotes += 1
				}
					
			} else if newWord.last == "\'" {
				if inSingleQuote {
						newWord.removeLast()
						inSingleQuote = false
						totalQuotes += 1
						
						let lastIndex = newArguments.endIndex - 1
						
						newWord = "\(newArguments[lastIndex]) \(newWord)"
						newArguments.removeLast()
				} else {
						error(err: "Single quote used incorrectly.")
				}
					
				} else if inSingleQuote {
					let lastIndex = newArguments.endIndex - 1
					
					newWord = "\(newArguments[lastIndex]) \(newWord)"
					newArguments.removeLast()
					
			}
				newArguments.append(newWord)
				
		}
			
		    if totalQuotes % 2 != 0 {
				error(err: "Single quote used incorrectly. Uneven number of quotes")
			}
	
		task = newArguments
		let newCommandView = CommandView()

		if isVerb(str: task.first!) {
			
			if task.first == "wait" {
				task = ["sleep", "0"]
				newCommandView.wait = true
			}
			
		} else {
            let fileManager = FileManager()
            let fileExists = fileManager.fileExists(atPath: task.first!)
            if !fileExists {
                error(err: "\(task.first!) does not exist.")
            }
            // Confirm file exists here
			//let errorVerb = task.first!
			//error(err: "\(errorVerb) is not a valid jamf verb. Command must be a jamf binary command or 'sleep <seconds>' or 'wait'. \nCheck out 'jamf help' for the list of jamf verbs.")
		}
		
		newCommandView.jssCommand = task
		newCommandView.taskName = taskName
		newCommandView.isFile = isFile
		
		
		if isFile {
			newCommandView.htmlString = nil
		} else {
			newCommandView.localFile = (nil, nil)
		}
		return newCommandView
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	func applicationWillFinishLaunching(_ notification: Notification) {
		
		var blurryBackgroundHeight: Int = 0
		var blurryBackgroundWidth: Int = 0

		
		var fullscreen = false
		var blurryBackground = false
		
		var file:LocalWebFile = (nil, nil)
		let numberOfArguments = Int(CommandLine.argc)
		var index = 1
		while index < numberOfArguments {
		let arg = CommandLine.arguments[index]
		var jamfVerbAndName = ""
			
		switch arg {
			
		case "--file", "-f":
			
			if let filePath = CommandLine.arguments[index + 1] as String? {
		
				file = validateAndReturnLocalWebFile(filePath: filePath as NSString)
				
				if let verbAndName = CommandLine.arguments[index + 2] as String? {
					jamfVerbAndName = verbAndName
					let newCommandView = getCommandView(isFile: true, jamfVerbAndName: jamfVerbAndName)
					newCommandView.localFile = file
					commandViews.append(newCommandView)
				}
				else {
					error(err: "No jamf command specified.")
				}
			} else {
					error(err: "File path not specified.")
			}
				
			index += 2
		case "--html", "-html":
			if let htmlString = CommandLine.arguments[index + 1] as String? {
				
				if let verbAndName = CommandLine.arguments[index + 2] as String? {
					jamfVerbAndName = verbAndName
					let newCommandView = getCommandView(isFile: false, jamfVerbAndName: jamfVerbAndName)
					newCommandView.htmlString = htmlString
					
					commandViews.append(newCommandView)
				}
				else {
					error(err: "No jamf command specified.")
				}
					
								} else {
				error(err: "HTML not specified.")
			}
			
			index += 2
		case "--output", "-o":
			if let logPath = CommandLine.arguments[index + 1] as String? {
				//Check if file exists
				if FileHandle(forWritingAtPath: logPath) != nil {
					error(err: "\(logPath) already exists.")
				} else {
					self.logPath = logPath
				}
			}
			index += 1
		case "--height", "-h":
				if let newHeight = CommandLine.arguments[index + 1] as String? {
					if Int(newHeight) == nil {
						error(err: "Height must be an integer value")
					} else {
						if Int(newHeight)! >= heightMin && Int(newHeight)! < heightMax {
							self.height = Int(CommandLine.arguments[index + 1])!
						} else {
							error(err: "Height value of \(newHeight) is not within required bounds")
						}
					}
				}
				
				index += 1
		case "--width", "-w":
				if let newWidth = CommandLine.arguments[index + 1] as String? {
					if Int(newWidth) == nil {
						error(err: "Width must be an integer value")
					} else {
						if Int(newWidth)! >= widthMin && Int(newWidth)! < widthMax {
							self.width = Int(CommandLine.arguments[index + 1])!
						} else {
							error(err: "Width value of \(newWidth) is not within required bounds")
						}
					}
				}
				index += 1
		case "--title", "-t":
				let titleArg = CommandLine.arguments[index + 1]
				self.title = titleArg
				index += 1
		case "--fullscreen":
				fullscreen = true
		case "--blurry":
				blurryBackground = true
		case "--help", "-h":
				displayManPage()
		case "--showTitlebar", "--showTitleBar", "--showtitlebar":
				showTitleBar = true
        case "-NSDocumentRevisionsDebugMode":
				index += 1
				break;
		default:
				error(err: "Unknown argument: \(arg)")
			}
			index += 1
		}
		
		
		if commandViews.count < 1 {
			error(err: "Not enough valid arguments")
		} else {
			NSApp.activate(ignoringOtherApps: true)
            
			let windowFirst = NSApplication.shared.windows.first!
			windowFirst.delegate = self
			windowFirst.makeKeyAndOrderFront(self)
			
			if showTitleBar {
				windowFirst.styleMask = NSWindow.StyleMask(rawValue: 263)
                windowFirst.title = self.title
			} else {
                windowFirst.styleMask = NSWindow.StyleMask(rawValue: 262)
			}
			
			var windowFrame = windowFirst.frame
			
			if fullscreen {
				if blurryBackground {
					error(err: "Cannot be fullscreen and have a blurry background")
				} else {
					windowFirst.styleMask = NSWindow.StyleMask(rawValue: 262)

					let fullscreenOptions:NSApplication.PresentationOptions = ([NSApplication.PresentationOptions.hideDock,NSApplication.PresentationOptions.disableAppleMenu,NSApplication.PresentationOptions.disableForceQuit,NSApplication.PresentationOptions.disableProcessSwitching,NSApplication.PresentationOptions.disableSessionTermination,NSApplication.PresentationOptions.disableHideApplication,NSApplication.PresentationOptions.autoHideDock,NSApplication.PresentationOptions.autoHideMenuBar,NSApplication.PresentationOptions.autoHideToolbar])
					
					
					let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions :
						NSNumber(value: fullscreenOptions.rawValue)]
					
					width = Int((NSScreen.main?.frame.width)!) - (marginWidth * 2)
					height = Int((NSScreen.main?.frame.height)!) - (marginWidth * 2)
					windowFirst.collectionBehavior = NSWindow.CollectionBehavior.fullScreenPrimary
					windowFrame = (NSScreen.main?.frame)!
					windowFirst.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.screenSaverWindow)))
					
					windowFirst.contentView?.enterFullScreenMode(NSScreen.main!, withOptions: optionsDictionary)
					windowFirst.contentView?.wantsLayer = true
				}
				
			} else if blurryBackground {
				windowFirst.styleMask = NSWindow.StyleMask(rawValue: 262)
				
				let fullscreenOptions:NSApplication.PresentationOptions = ([NSApplication.PresentationOptions.hideDock,NSApplication.PresentationOptions.disableAppleMenu,NSApplication.PresentationOptions.disableForceQuit,NSApplication.PresentationOptions.disableProcessSwitching,NSApplication.PresentationOptions.disableSessionTermination,NSApplication.PresentationOptions.disableHideApplication,NSApplication.PresentationOptions.autoHideDock,NSApplication.PresentationOptions.autoHideMenuBar,NSApplication.PresentationOptions.autoHideToolbar])
				
				
				let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions :
					NSNumber(value: fullscreenOptions.rawValue)]
				
				blurryBackgroundWidth = width
				blurryBackgroundHeight = height
				
				width = Int((NSScreen.main?.frame.width)!) - (marginWidth * 2)
				height = Int((NSScreen.main?.frame.height)!) - (marginWidth * 2)
				windowFirst.collectionBehavior = NSWindow.CollectionBehavior.fullScreenPrimary
				windowFrame = (NSScreen.main?.frame)!
				windowFirst.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.screenSaverWindow)))
				
				windowFirst.contentView?.enterFullScreenMode(NSScreen.main!, withOptions: optionsDictionary)
				windowFirst.contentView?.wantsLayer = true
				
			} else {
			
				let appWindowHeight = height + (marginWidth * 2)
				let appWindowWidth = width + (marginWidth * 2)
				
				windowFrame.size = NSSize(width: CGFloat(appWindowWidth), height: CGFloat(appWindowHeight))
                
				let xPos:CGFloat = CGFloat(widthMax/2) - CGFloat(appWindowWidth/2)
				let yPos = (heightMax/2) - (appWindowHeight/3)
                
				let origin = NSPoint(x: CGFloat(xPos), y: CGFloat(yPos))
				
				windowFrame.origin = origin
            }
			
            windowFirst.setFrame(windowFrame, display: true)
			let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
			let vc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "vc")) as! CustomViewController
			vc.view.setFrameSize(windowFrame.size)
            
			if blurryBackground {
	
				vc.blurryBackground = true
				vc.blurryBackgroundMarginLeft = Int(widthMax/2) - Int(blurryBackgroundWidth/2)
				vc.blurryBackgroundHeight = blurryBackgroundHeight
				vc.blurryBackgroundWidth = blurryBackgroundWidth
				
				vc.blurryBackgroundMarginTop = (heightMax - blurryBackgroundHeight)/2

			}
            
			vc.setSubViews(webviewWidth: width, webviewHeight: height, margin: marginWidth)
				
			if (logPath != nil) {
				vc.setOutputPath(logPath: logPath!)
			}
			vc.setCommandViews(commandviews: commandViews)
			windowFirst.contentViewController = vc
		}
	}
}

