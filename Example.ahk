/*
Script that can be used to try out the various modes and tokens
Only one Load() line should be commented out at a time
Other options can typically be combined
*/
#SingleInstance force
#include Lib\SequenceSender.ahk

; Clear the debug window
OutputDebug, DBGVIEWCLEAR

ss := new SequenceSender()
	; --- Options --- Any number of these can be enabled at once
	.Debug(true)				; Disable sending of actual keys, just log to Debug
	;~ .BlindMode(true)			; Turn on Blind send mode
	;~ .Repeat(false)			; Disable Repeating
	;~ .ResetOnStart(false)		; Disable Reset on Start
	;~ .Load("abc")				; Basic send
	; --- SequenceStrings --- Only uncomment one of these at a time
	.Load("^c^{a}[Sleep, 100]abcdef{Left}^{c}[RandSleep, 10, 100]^{v}^{Right}")			; Sleep Tokens
	;~ .Load("{1}[WinActivate, ahk_class Notepad]{2}[WinWaitActive, ahk_class Notepad]{3}")	; Window Tokens
	;~ .Load("[SetKeyDelay, 1000, 1000]abc[SetKeyDelay, 50, 50]def")							; KeyDelay Token
return

$F12::ss.Toggle()

^Esc::
	ExitApp
