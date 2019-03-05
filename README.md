# Trigger
## macOS command line utility for displaying a web view while simultaneously running a process
It is written in Swift 3 and has been testedd and confirmed to work on macOs 10.12.6 up to 10.14.3

[You can get the latest pre-built Trigger pkg from here](https://s3.amazonaws.com/taniacomputer/Trigger+v1.4.pkg) (pkg installs Trigger.app in /usr/local) 

## Usage:

>Trigger.app/Contents/MacOS/Trigger WEBVIEW_1 COMMAND_1 WEBVIEW_2 COMMAND_2 … [OPTIONS]

Trigger displays a web view while simultaneously executing a command. Once the command finishes executing Trigger moves on to the next web view/command pair.

### WEBVIEW
The local HTML file or HTML string to display
-f, –file <path to file>
OR
-html, –html <HTML string>

### COMMAND
The command to execute. Command can be a shell command or a jamf binary command.

**Example shell commands:** 

'sleep 5'

'/tmp/a_script.sh'

"/usr/sbin/installer -package ‘/tmp/CocoaDialog v2.1.1.pkg’ -target /"

Note the single quotes to wrap around the filename with spaces.

**Accepted jamf commands:** 

All jamf verbs, although be warned that Trigger has only been tested with jamf binary versions 9.61 – 9.97, so far.
Note: Trigger assumes that the binary is in /usr/local/bin/jamf. Specify fullpath if you relocated the binary.

Trigger needs to be run as root to run jamf commands.

**Example jamf commands:**. 
>"policy -trigger ‘microsoft office'"  

>'policy -trigger vlc'

>recon

**There is one special Trigger commands: wait** 

wait displays the webView until a particular link on the presented HTML.

>Trigger.app/Contents/MacOS/Trigger WEBVIEW wait 

What occurs once the link is clicked depends on the url:  
– A link to "next", eg. `<a href=”http://next”>NEXT</a>`, makes Trigger proceed to the next web view/command pair.  
– A link to "formParse", eg. `<a href=”http://formParse”>Submit</a>`, will inspect any form values and return the results to stdout. before proceeding to the next web view/command pair.  
– A link to "quit", eg. `<a href=”http://quit”>Done</a>`, terminates Trigger.  
Be sure to add http:// in the link URL (required by macOS 10.12.4+)

### COMMAND,NAME
If an output file is specified (see '-o, –output' option below), all named commands have their stdout and success status written to this file.
A command is named by appending a comma followed by the name in quotations.
eg. "policy -trigger mcafee","McAfee Security Agent"

### OPTIONS
**-t,–title <title>**
Title of the Trigger window.
By default there is no title.

**-h, –height <window height>**
Height, in pixels, of content window.
Default height is 320px.

**-w, –width <window width>**
Width, in pixels, of content window.
Must be within the minimum and maximum width of the content window.
Default width is 360px.

**–noTitleBar, –notitlebar**
Hides the titlebar.

**–fullscreen**
Puts the Trigger webView in fullscreen mode, and disables process switching, the dock, the apple menu, the menubar, and although the expose funtion key still works the user will be unable to switch to another application. Shift-command-Q for logout will work.
There is no title bar when in fullscreen mode.

**–blurry**
Applies a blurry overlay to the screen, behind the webView. 
Cannot be used in conjunction with –fullscreen.

**-o, –output <output file fullpath>**
Creates an output html file. All named commands have their results written to it.
  
### EXAMPLES
>/usr/local/Trigger.app/Contents/MacOS/Trigger --file /tmp/power_prompt.html wait --width 800 --height 600

>/usr/local/Trigger.app/Contents/MacOS/Trigger --file /tmp/progress_wheel.html 'sleep 5'

>/usr/local/Trigger.app/Contents/MacOS/Trigger --file /tmp/installing_word.html "jamf policy -trigger 'word 2019'" --width 800 --height 600 --blurry

>/usr/local/Trigger.app/Contents/MacOS/Trigger --file /tmp/installing_word.html "/usr/sbin/installer -package '/tmp/CocoaDialog v2.1.1.pkg' -target /" --fullscreen
