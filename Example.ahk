#include SequenceSender.ahk

#SingleInstance force
OutputDebug, DBGVIEWCLEAR

;~ ss := new SequenceSender("^{Home}[Sleep 100]+^{Right}^{c}[RandSleep 10, 100]^{v}")
ss := new SequenceSender()
	.Debug(true)
	.BlindMode(true)
	.Load("^c^{a}[Sleep 100]abcdef{Right}^{c}[RandSleep 10, 100]^{v}^{Right}")
	;~ .Repeat(true)
	;~ .ResetOnStart(true)
	;~ .SetTokenChars("(", ")")
	;~ .SetTokenChars("{", "}")	; Should throw error
	.ResetOnStart(false)
	.Load("{1}{2}{3}{4}{5}{6}{7}{8}{9}")
	;~ .Load("^{Home}[Sleep 100]+^{Right}^{c}[RandSleep 10, 100]^{v}")
	;~ .Load("^c[Sleep 100]abcdef{Right}^{c}[RandSleep 10, 100]^{v}")
	;~ .Load("^c^{a}[Sleep 100]abcdef{Right}[RandSleep 10, 100]^{v}^{Right}")
	;~ .Load("^{Home}(Sleep 100)+^{Right}^{c}(RandSleep 10, 100)^{v}")
return

F12State := 0

F12::
	if (F12State)
		return
	F12State := 1
	;~ toggle := !toggle
	if (!ss._TimerRunning)
		ss.Start()
	else
		ss.Stop()
	return

F12 up::
	F12State := 0
	return
