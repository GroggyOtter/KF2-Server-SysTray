	; Starts KF2 server and immediately hides it.
	; There should be a KF2 icon in the system tray to show when the script is running.

	;=========================== Change these to match your settings =======================
	; The path to KFServer.exe on your computer
	global	yourServerPath	:=	"D:\Server\KF2\steamapps\common\killingfloor2\Binaries\Win64\KFServer"
	; Arguments you use to start, such as first map
	global	yourServerArgs	:=	"KF-Blockfort-v2"
	;=========================== End user settings ===========================

	; Allow only 1 instance to be ran at a time
	#SingleInstance, Force

	; Main server path with args
	global	kf2ServerPath	:=	yourServerPath " " yourServerArgs

	; Admin check
	; If the script isn't working, remove the ; from the beginning of the next line.
	; It'll force admin mode which may solve any issues.
	;AdminCheck()

	; Download KF2 icon from the Internet and make custom tray
	MakeCustomSysTrayIcon()

	; Create content of tray menu
	MakeCustomSysTray()

	; End AES
	Exit

	;=========================== Hotkeys Section =========================== 
	; Hotkey to hide and show the terminal window
	; You can prefix any key with a modifier key (listed below)
	; + is Shift	! is Alt	^ is control
	; ^F1 would be Ctrl+F1
	; See more about hotkeys here: https://autohotkey.com/docs/Hotkeys.htm
	^F1::
		ShowHide()
	return
	;=========================== End Hotkeys =========================== 


	;=========================== Funcs and Subs =========================== 
	MakeCustomSysTrayIcon(){
		; URL of ICO
		url		:= "https://raw.githubusercontent.com/GroggyOtter/Images/master/kf2_icon_pack_GroggyOtter.ico"
		; Local location
		icoLoc	:= A_AppData . "\KF2 Server Script\img\"
		; Local name
		icoName	:= "kf2.ico"
		; Full Path
		icoPath	:= icoLoc . icoName
		; Tracks errors
		err		:= false
		
		; Ensure directory is created
		FileCreateDir, % icoLoc
		
		; See if icon exists locally. If not, download it.
		Loop
		{
			; Download the file
			URLDownloadToFile, % url, % icoPath
			
			; Delay for download
			Sleep, 1000
			
			; If not successful in 60 tries (roughly 1 min), throw an error message and let user decide if they want to use the default AHK icon.
			if (A_Index > 30){
				MsgBox, 0x4, Error, There was a problem downloading the KF2 icon.`n`nDo you want to continue and use the standard "Green H" AutoHotkey icon?`n`nPress Yes to continue`nPress No to close this script.
				IfMsgBox, No
				{
					MsgBox Exiting script.
					ExitApp
				}
				IfMsgBox, Yes
				{
					err		:= true
					Break
				}
			}
			
		}Until (FileExist(icoPath) != "")
		
		; If there was no error before, make custom systray
		if (err = false)
		{
			; Apply icon to sys tray
			Menu, Tray, Icon, % icoPath
		}
		
		return
	}

	; Creates custom items in system tray
	MakeCustomSysTray(){
		; Removes standard items
		Menu, Tray, NoStandard
		
		; Show/Hide server window
		Menu, Tray, Add, Show/Hide Server Window, KF2ShowHide
		
		; Divider
		Menu, Tray, Add
		
		; Launch Server
		Menu, Tray, Add, Server Launch, KF2ServerLaunch
		
		; Divider
		Menu, Tray, Add
		
		; Exit Script
		Menu, Tray, Add, Exit, ExitScript
		
		; Default show/hide
		Menu, Tray, Default, Show/Hide
		
		return
	}
	; Menu Subs
	KF2ShowHide:
		ShowHide()
	return
	KF2ServerLaunch:
		KF2ServerLaunch()
	return
	ExitScript:
		ExitApp
	Exit

	; Launch server
	KF2ServerLaunch(){
		; If server isn't running
		if !ProcessExists("KFServer.exe"){
			; Prompt user for password. Use hidden text.
			InputBox, pw, Password Prompt, Enter your password, HIDE
			
			; Run server with args
			; Store PID to global kf2ServerPID
			Run, % kf2ServerPath "?adminpassword=" pw
			
			; Clear password variable so it's not sitting in memory
			pw	:=	""
			
			; Wait for process to exist on system
			Loop{
				Sleep, 1000
				; Error out at 30 attempts
				if (A_Index > 30){
					MsgBox,,Error, There was an error starting the KF2Server.`nMake sure the path at the top of the script is correct.
					ExitApp
				}
			}Until (ProcessExists("KFServer.exe"))
		}
		return
	}

	; Show/hide terminal window
	ShowHide(){
		name	:= "ahk_exe KFServer.exe"
		; If window doesn't exist, show it
		IfWinNotExist, % name
			WinShow, % name
		; If window does exist, hide it
		Else
			WinHide, % name
		return
	}

	; Check if process exists
	ProcessExists(p){
		; Process exist sets errorlevel to PID
		; If not running, returns a 0
		Process, Exist, % p
		return ErrorLevel
	}

	AdminCheck(){
		if not A_IsAdmin {
		   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
		   ExitApp
		}
		return
	}

	;=========================== End Script =========================== 
