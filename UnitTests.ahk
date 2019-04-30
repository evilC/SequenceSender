#SingleInstance force
#include SequenceSender.ahk
#Persistent

Gui, Add, Edit, w500 h400 hwndhOutput
Gui, Show, NoActivate

ss := new SequenceSender()

Assert("Basic Key Chunking",ss,"ab^!c{d}^!{Space}", [{Type: 1, RawText: "a"}
	, {Type: 1, RawText: "b"}
	, {Type: 1, RawText: "^!c"}
	, {Type: 1, RawText: "{d}"}
	, {Type: 1, RawText: "^!{Space}"}])
Assert("Differentiate Keys and Tokens",ss,"ab^!c{d}[Sleep 100]^!{Space}[RandSleep 10, 100]", [{Type: 1, RawText: "a"}
	, {Type: 1, RawText: "b"}
	, {Type: 1, RawText: "^!c"}
	, {Type: 1, RawText: "{d}"}
	, {Type: 2, RawText: "Sleep 100"}
	, {Type: 1, RawText: "^!{Space}"}
	, {Type: 3, RawText: "RandSleep 10, 100"}])
Assert("Symbol Hotkeys Basic Test",ss,"^#%%", [{Type: 1, RawText: "^#%"}
	, {Type: 1, RawText: "%"}])
return

^Esc::
GuiClose:
	ExitApp

Assert(name, seqSender, seqStr, expected){
	err := 0
	results := seqSender.__BuildSeq(seqStr)
	al := results.Length()
	el := expected.Length()
	Loop % el {
		a := results[A_Index]
		e := expected[A_Index]
		for k, v in e {
			str := "FAIL: " name " - "
			if (!a.HasKey(k)){
				str .= "Result " A_Index " does not have key " k
				WriteLog(str)
				break
			}
			if (a[k] != v){
				str .= "Expected position " A_Index " to be " v ", but found " a[k]
				WriteLog(str)
				break
			}
		}
	}
	if (al != el){
		WriteLog("FAIL: " name " - Expecting " el " matches, but got " al " matches")
		return
	}
	WriteLog("PASS: " name)
}

WriteLog(text){
	global hOutput
	text .= "`r`n"
	AppendText(hOutput, &text)
}

AppendText(hEdit, ptrText) {
    SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ;WM_GETTEXTLENGTH
    SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit% ;EM_SETSEL
    SendMessage, 0x00C2, False, ptrText,, ahk_id %hEdit% ;EM_REPLACESEL
}
