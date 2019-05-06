#SingleInstance force
; Load the library
#include Lib\SequenceSender.ahk

; Load a sequence of the keys 1-9
ss := new SequenceSender().Load("{1}{2}{3}{4}{5}{6}{7}{8}{9}")
return

; Toggle on and off hotkey
$F11::ss.Toggle()

; Hold to spam hotkey
$F12::ss.Start()
$F12 up::ss.Stop()