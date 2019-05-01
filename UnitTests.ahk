#SingleInstance force
#include Lib\SequenceSender.ahk
#Persistent

Gui, Add, Edit, w500 h400 hwndhOutput
Gui, Show, NoActivate

ss := new SequenceSender()

Assert("Basic Key Chunking",ss,"ab^!c{d}^!{Space}", [{Type: 1, SendStr: "a"}
	, {Type: 1, SendStr: "b"}
	, {Type: 1, SendStr: "^!c"}
	, {Type: 1, SendStr: "{d}"}
	, {Type: 1, SendStr: "^!{Space}"}])
	
Assert("Differentiate Keys and Tokens",ss,"ab^!c{d}[Sleep, 100]^!{Space}[RandSleep, 10, 100]", [{Type: 1, SendStr: "a"}
	, {Type: 1, SendStr: "b"}
	, {Type: 1, SendStr: "^!c"}
	, {Type: 1, SendStr: "{d}"}
	, {Type: 2, TokenName: "Sleep", SleepTime: "100"}
	, {Type: 1, SendStr: "^!{Space}"}
	, {Type: 2, TokenName: "RandSleep", MinSleep: 10, MaxSleep: 100}])

Assert("Symbol Hotkeys Basic Test",ss,"^#%%", [{Type: 1, SendStr: "^#%"}
	, {Type: 1, SendStr: "%"}])

Assert("Token chars in braces",ss,"{[}{]}", [{Type: 1, SendStr: "{[}"}
	, {Type: 1, SendStr: "{]}"}])

Assert("Token chars in braces with token",ss,"{[}[Sleep, 100]{]}", [{Type: 1, SendStr: "{[}"}
	, {Type: 2, TokenName: "Sleep"}
	, {Type: 1, SendStr: "{]}"}])

return

^Esc::
GuiClose:
	ExitApp

Assert(name, seqSender, seqStr, expected){
	failed := 0
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
				failed := 1
				break
			}
			if (a[k] != v){
				str .= "Expected position " A_Index ", key " k " to be " v ", but found " a[k]
				failed := 1
				WriteLog(str)
				break
			}
		}
	}
	if (al != el){
		WriteLog("FAIL: " name " - Expecting " el " matches, but got " al " matches")
		failed := 1
		return
	}
	if (!failed){
		WriteLog("PASS: " name)
	}
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
