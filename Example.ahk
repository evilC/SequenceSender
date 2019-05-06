#SingleInstance force
#include Lib\SequenceSender.ahk

OutputDebug, DBGVIEWCLEAR

ss := new SequenceSender()
	.Debug(true)				; Disable sending of actual keys, just log to Debug
	;~ .BlindMode(true)			; Turn on Blind send mode
	;~ .Repeat(false)			; Disable Repeating
	;~ .ResetOnStart(false)		; Disable Reset on Start
	;~ .Load("abc")				; Basic send
	;~ .Load("^c^{a}[Sleep, 100]abcdef{Left}^{c}[RandSleep, 10, 100]^{v}^{Right}")			; Sleep Tokens
	.Load("{1}[WinActivate, ahk_class Notepad]{2}[WinWaitActive, ahk_class Notepad]{3}")	; Window Tokens
	;~ .Load("[SetKeyDelay, 1000, 1000]abc[SetKeyDelay, 50, 50]def")							; KeyDelay Token
return

$F12::ss.Toggle()

^Esc::
	ExitApp
