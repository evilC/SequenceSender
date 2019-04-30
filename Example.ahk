#include Lib\SequenceSender.ahk

#SingleInstance force
OutputDebug, DBGVIEWCLEAR

ss := new SequenceSender()
	.Debug(true)				; Disable sending of actual keys, just log to Debug
	;~ .BlindMode(true)			; Turn on Blind send mode
	;~ .Repeat(false)			; Disable Repeating
	;~ .ResetOnStart(false)		; Disable Reset on Start
	.Load("^c^{a}[Sleep 100]abcdef{Left}^{c}[RandSleep 10, 100]^{v}^{Right}")
	;~ .Load("{1}{2}{3}{4}{5}{6}{7}{8}{9}")
	;~ .Load("^{Home}[Sleep 100]+^{Right}^{c}[RandSleep 10, 100]^{v}")
	;~ .Load("^c[Sleep 100]abcdef{Right}^{c}[RandSleep 10, 100]^{v}")
	;~ .Load("^c^{a}[Sleep 100]abcdef{Right}[RandSleep 10, 100]^{v}^{Right}")
	;~ .Load("^{Home}(Sleep 100)+^{Right}^{c}(RandSleep 10, 100)^{v}")
return

F12::ss.Toggle()

^Esc::
	ExitApp
