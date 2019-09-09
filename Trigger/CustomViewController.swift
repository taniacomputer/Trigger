//
//  CustomViewController.swift
//  Trigger
//
//  Created by Tania  on 19/10/2016.
//  Copyright © 2016 TaniaComputer. All rights reserved.
//

import Cocoa
import WebKit


typealias LocalWebFile = (String?, String?)
class CommandView {
	var isFile: Bool = false
	var localFile: LocalWebFile = (nil,nil)
	var htmlString: String? = nil
	var jssCommand: [String] = [""]
	var taskName: String? = nil
	var wait: Bool = false
}
class Task {
	var name:String? = nil
	var task = Process()
	var output = Pipe()
	var error = Pipe()
}

class CustomViewController: NSViewController, WKNavigationDelegate, WKUIDelegate, NSURLConnectionDelegate {
	var blurryBackground: Bool = false
	var blurryBackgroundWidth: Int = 0
	var blurryBackgroundHeight: Int = 0
	var blurryBackgroundMarginLeft: Int = 0
	var blurryBackgroundMarginTop: Int = 0
	
	@IBOutlet weak var progressIndicator: NSProgressIndicator!
	var commandviews = [CommandView]()
	var taskArray = [Task]()
	var logPath:String? = nil
	
	var webView = WKWebView()
	var cachedWebView:WKWebView? = nil
	var margin = 5
	var width = 0
	var height = 0
  var index = 0
	
	var timer = Timer()
	
	var firstWebView = true
	
	func loadWebView(cv: CommandView){
		if cv.isFile {
			self.loadLocalFile(fullPath: (cv.localFile.0)!, directory: (cv.localFile.1)!)
    } else {
			self.webView.loadHTMLString(cv.htmlString!, baseURL: nil)
		}
	}
	
  func createTaskArray() {
		var path = "/usr/local/bin/jamf"
		let max = commandviews.count - 1
		for i in 0...max {
			if commandviews[i].jssCommand.first == "sleep" {
				path = "/bin/sleep"
				commandviews[i].jssCommand.remove(at: 0)
			} else {
				if commandviews[i].jssCommand.first?.first == "/" {
					path = commandviews[i].jssCommand.first!
					commandviews[i].jssCommand.remove(at: 0)
				} else {
					path = "/usr/local/bin/jamf"
				}
			}
			
			let t = Task()
			if commandviews[i].taskName != nil {
				t.name = commandviews[i].taskName!
			} 
			t.task.launchPath = path
			t.task.arguments = commandviews[i].jssCommand
			t.output = Pipe()
			t.error = Pipe()
			t.task.standardOutput = t.output
			t.task.standardError = t.error
			taskArray.append(t)
			
		}
	}
	
	func runTV(index: Int) {
		if self.commandviews.count == 0 {
			quitApp()
		} else {
			loadWebView(cv: self.commandviews[index])
			runTask(index: index, t: self.taskArray[index]) {
			(exitCode) in
			let currentCommandWaitStatus = self.commandviews[0].wait
			//At this point I'm deleting the task just completed.
			self.commandviews.remove(at: index)
			self.taskArray.remove(at: index)
			
			if  currentCommandWaitStatus != true {
				if index < self.commandviews.count {
					self.runTV(index: 0)
				} else {
					self.quitApp()
					}
				}
			}
		}
	}

    func runTask(index: Int, t:Task, completion: @escaping (_ exitCode: Int32) -> ()) {
        DispatchQueue.global(qos: .background).sync {
            var htmlResult = ""
			t.task.launch()
			t.task.terminationHandler = { nstask in
				var output: String = ""
				var error : String = ""
				var name : String = ""
				if t.name != nil {
				let outdata = t.output.fileHandleForReading.readDataToEndOfFile()
					if var string = String(data: outdata, encoding: .utf8) {
						string = string.trimmingCharacters(in: .newlines)
						output = string
					}
					let errdata = t.error.fileHandleForReading.readDataToEndOfFile()
					if var string = String(data: errdata, encoding: .utf8) {
						string = string.trimmingCharacters(in: .newlines)
						error = string
					}
					
					if t.task.terminationStatus == 1 || output.contains("No policies were found for the") {
						if output.count > 0 {
							output = "<li>\(output)</li>"
						}
						if error.count > 0 {
							error = "<li>\(error)</li>"
						}
						
						name = "<b style=\"color:red;\">\(t.name!) : Failure</b>"
						htmlResult = "\(name)<br /><ul>\(output)\(error)</ul>"
					
					} else {
						name = "<b style=\"color:green;\">\(t.name!) : Success</b>"
						htmlResult = "\(name)<br />"
					}
					
					self.resultToLog(result: htmlResult)
				}
				
				completion(Int32(1))
	  	}
	  }
	}
	
	func resultToLog(result:String) {
		if (logPath != nil) {
			if let fileHandle = FileHandle(forWritingAtPath: logPath!) {
				//Append to file
				fileHandle.seekToEndOfFile()
				fileHandle.write("\n".data(using: String.Encoding.utf8)!)
				fileHandle.write(result.data(using: String.Encoding.utf8)!)
			}
			else {
				//Create new file
				do {
					try result.write(toFile: logPath!, atomically: true, encoding: String.Encoding.utf8)
					
				} catch {
                    print("Error creating log file")
				}
			}
		}
	}
	
	func setOutputPath(logPath:String) {
		self.logPath = logPath
	}

	func quitApp(){
        DispatchQueue.main.async {
            self.webView.stopLoading()
            NSApplication.shared.terminate(self)
	
        }
    }
    
	func setSubViews(webviewWidth:Int, webviewHeight: Int, margin: Int) {
		webView.wantsLayer = true
		webView.layer?.masksToBounds = true
		webView.navigationDelegate = self
		webView.uiDelegate = self

		
		if blurryBackground {
			
			self.width = blurryBackgroundWidth
			self.height = blurryBackgroundHeight
			
			self.view.layerUsesCoreImageFilters = true
						if let blurFilter = CIFilter(name: "CIGaussianBlur",
			                             withInputParameters: [kCIInputRadiusKey: 300]) {
							let satFilter = CIFilter(name: "CIColorControls")
							satFilter?.setValue(2, forKey: "inputSaturation")
								self.view.wantsLayer = true
								self.view.layer?.backgroundColor = NSColor.clear.cgColor
                                self.view.layer?.backgroundFilters = [satFilter!, blurFilter]
							}
			self.webView = WKWebView(frame: CGRect(x: CGFloat(blurryBackgroundMarginLeft), y: CGFloat(blurryBackgroundMarginTop), width: CGFloat(width), height: CGFloat(height)))

			
		} else {
			self.width = webviewWidth
			self.height = webviewHeight
			self.margin = margin
			self.webView = WKWebView(frame: CGRect(x: CGFloat(self.margin), y: CGFloat(self.margin), width: CGFloat(width), height: CGFloat(height)))

		}
	
		self.view.addSubview(self.webView)
	}
	
	override func viewDidAppear() {
		createTaskArray()
		runTV(index: 0)
	}
	
	func loadLocalFile(fullPath: String, directory: String) {
		//let fullPath = NSURL(fileURLWithPath: "file://\(fullPath)")
		//let dir = NSURL(fileURLWithPath: "file://\(directory)")
        let fullPath = NSURL(fileURLWithPath: "\(fullPath)")
        let dir = NSURL(fileURLWithPath: "\(directory)")
        print(fullPath)
        print(dir)
		if #available(OSX 10.11, *) {
			self.webView.loadFileURL(fullPath as URL, allowingReadAccessTo: dir as URL)
		} else {
			let request = NSURLRequest(url: fullPath as URL)
			self.webView.load(request as URLRequest)
		}
		
	}
	
	override func viewWillAppear() {
		self.webView.navigationDelegate = self
		self.webView.uiDelegate = self
		
	}
	
	func setCommandViews(commandviews: [CommandView]) {
		self.commandviews = commandviews
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if !blurryBackground {
		progressIndicator.startAnimation(self)
        }
	}
	
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !blurryBackground {
		progressIndicator.stopAnimation(self)
        }
    }
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		
		if (navigationAction.request.url?.absoluteString.contains("quit"))! {
			quitApp()
		} else if (navigationAction.request.url?.absoluteString.contains("next"))! {
			//decisionHandler(.allow)
			runTV(index: 0)
		} else if (navigationAction.request.url?.absoluteString.contains("formparse"))! {
			getWebFormData(wv: self.webView) {
				(result: Int) in
				self.runTV(index: 0)
			}
		}
		
		decisionHandler(.allow)

  }
	
	func getJavascript() -> String {
		let fileLocation = Bundle.main.path(forResource: "serialize", ofType: "js")!
		let text : String
		var script = ""
		do
		{
			text = try String(contentsOfFile: fileLocation)
			let lines : [String] = text.components(separatedBy: "\n")
			
			//let lines : [String] = text.componentsSeparatedByString("\n")
			script = lines.joined(separator: " ")
		}
		catch
		{
			print("Error")
		}
		return script
	}
	
	func getWebFormData(wv: WKWebView, completion: @escaping (_ result: Int) -> Void) {
		wv.stopLoading()
		let script = getJavascript()
		wv.evaluateJavaScript(script, completionHandler: { (result: Any?, error: Error?) -> Void in
			if error == nil {
				if result != nil {
					self.parseWebFormResults(str: result! as! String)
				}
			}
			else {
				NSLog("evaluateJavaScript error : %@", error!.localizedDescription)
			}
			completion(1)
		})
		
		}
	
	func parseWebFormResults(str:String) {
      
        let parsedString = str.components(separatedBy: "&")
		for comp in parsedString {
            let compDecoded = comp.removingPercentEncoding
			print(compDecoded ?? "Error")
		}
	}
	
	func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
		let myPopup: NSAlert = NSAlert()
		myPopup.icon = NSImage(named: NSImage.Name(rawValue: "alertcat"))
		myPopup.messageText = " "
		myPopup.informativeText = message
		myPopup.alertStyle = NSAlert.Style.informational
        myPopup.window.level = NSWindow.Level.screenSaver
		myPopup.addButton(withTitle: "OK")
        //myPopup.runModal()
		completionHandler()
	}
	
	func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
		let myPopup: NSAlert = NSAlert()
		myPopup.messageText = " "
		myPopup.icon = NSImage(named: NSImage.Name(rawValue: "logo"))
		myPopup.informativeText = message
        myPopup.window.level = NSWindow.Level.screenSaver

		myPopup.alertStyle = NSAlert.Style.informational
		myPopup.addButton(withTitle: "OK")
		//myPopup.runModal()
		completionHandler(true)
	}
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = " "
        myPopup.icon = NSImage(named: NSImage.Name(rawValue: "logo"))
        myPopup.informativeText = defaultText!
        myPopup.alertStyle = NSAlert.Style.informational
        myPopup.window.level = NSWindow.Level.screenSaver

        myPopup.addButton(withTitle: "OK")
        completionHandler(defaultText)
    }
	func connection(_ connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: URLProtectionSpace) -> Bool {
		return true
	}
	
}
