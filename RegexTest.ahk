#SingleInstance force
#include SequenceSender.ahk
#Persistent

Gui, Add, Edit, w500 h400 hwndhOutput
Gui, Show, NoActivate

p := new Parser()
Assert("Basic Key Chunking",p,"ab^!c{d}^!{Space}", ["a","b","^!c","{d}","^!{Space}"])
Assert("Differentiate Keys and Tokens",p,"ab^!c{d}[Token]^!{Space}[Token]^#%", ["a","b","^!c","{d}","[Token]","^!{Space}","[Token]", "^#%"])
Assert("Symbol Hotkeys Basic Test",p,"^#%%", ["^#%","%"])
return

^Esc::
GuiClose:
	ExitApp

class Parser {
	Mods := "+^!#<>"
	TokenRgx := "OU)(\[.+\])"
	
	__New(){
		this.SendRgx := "OU)([" this.Mods "]*({.+}|[^" this.Mods "]))"
	}
	
	Parse(seqStr){
		Seq := []
		chunks := []
		pos := 1
		lastPos := 0
		while (pos){
			pos := RegexMatch(SeqStr, this.TokenRgx, match, pos)

			if (pos == 0){
				chunks.Push(SeqStr)
				break
			} else {
				chunks.Push(SubStr(SeqStr, 1, pos - 1))
			}
			chunks.Push(SubStr(SeqStr, pos, match.Len))
			SeqStr := SubStr(SeqStr, pos + match.Len)
			if (SeqStr == "")
				break
		}
		
		for i, chunk in chunks {
			max := StrLen(chunk)
			if (SubStr(chunk, 1, 1) == "["){
				; Token
				tokenStr := SubStr(chunk, 2, max - 2)
				Seq.Push({Data: "[" tokenStr "]"})
			} else { 
				; Send String
				pos := 1
				while (pos){
					pos := RegexMatch(chunk, this.SendRgx, match, pos)
					if (pos == 0){
						break
					}
					m := match[1]
					Seq.Push({Data: m})
					
					pos += match.Len
					if (pos > max)
						break
				}
			}
		}
		return Seq
	}
}

Assert(name, parser, seqStr, expected){
	err := 0
	results := parser.Parse(seqStr)
	al := results.Length()
	el := expected.Length()
	Loop % el {
		a := results[A_Index].Data
		e := expected[A_Index]
		if (a != e){
			str := "FAIL: " name " - Expecting " e " at position " A_Index ", "
			if (A_Index >= el){
				str .= "but expected has no element"
			} else {
				str .= "but found " a
			}
			WriteLog(str)
			return
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
	text .= "`n"
	AppendText(hOutput, &text)
}

AppendText(hEdit, ptrText) {
    SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ;WM_GETTEXTLENGTH
    SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit% ;EM_SETSEL
    SendMessage, 0x00C2, False, ptrText,, ahk_id %hEdit% ;EM_REPLACESEL
}