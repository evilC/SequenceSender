/*
Example of using your own class as a Custom Token
*/
#SingleInstance force
#include Lib\SequenceSender.ahk
OutputDebug, DBGVIEWCLEAR

ss := new SequenceSender()
	.Debug(true)				; Disable sending of actual keys, just log to Debug
	.AddTokenClass("MyToken", "MyTokenClass")
	.Load("[MyToken, 1, 2, 3]")				; Load your token and pass 1, 2, 3 as parameters
return

$F12::ss.Toggle()

^Esc::
	ExitApp

; Derive from the base token object class!
class MyTokenClass extends BaseObjects.BaseTokenObj {
	/*
	; If you use a contstuctor, be sure to call base
	__New(parent, params){
		base.__New(parent, params)
		; ...
	}
	*/
	
	; Build is called when your token is loaded
	; It is passed parameters in an array
	Build(params){
		ToolTip % "Loaded params: " this.Join(", ", params)
	}
	
	; Execute is called when your token is triggered
	Execute(){
		Tooltip % "Executed stuff @ " A_TickCount
		; When done, call this.OnNext() to trigger the next item.
		; To simulate a "Sleep", pass a value to OnNext.
		this.OnNext(0)
	}
}