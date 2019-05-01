#include %A_LineFile%\..\BaseObjects.ahk
#include %A_LineFile%\..\DefaultTokens.ahk

class SequenceSender {
	Pos := 1
	_Aborting := 0
	_SequenceActive := 0
	_Repeat := true
	_ResetOnStart := true
	_Seq := []
	_Mods := "+^!#<>"
	_TokenRgx := "OU)(\[.+\])"
	_SeqTypeToName := ["Send", "Token"]
	_SeqNameToType := {}
	_Debug := false
	_BlindMode := 0
	; Class Names for Tokens
	_TokenClasses := {Sleep : "DefaultTokens.SleepObj"
		, DummyToken: "DefaultTokens.DummyToken"
		, RandSleep: "DefaultTokens.RandSleepObj"
		, WinWaitActive: "DefaultTokens.WinWaitActive"
		, WinWaitNotActive: "DefaultTokens.WinWaitNotActive"
		, WinActivate: "DefaultTokens.WinActivate"
		, ControlSend: "DefaultTokens.ControlSend"
		, SetKeyDelay: "DefaultTokens.SetKeyDelay"}
	
	__New(){
		this._SendRgx := "OU)([" this._Mods "]*({.+}|[^" this._Mods "]))"
		this.TickFn := this._Tick.Bind(this)
		for i, v in this._SeqTypeToName {
			this._SeqNameToType[v] := i
		}
	}
	
	Load(seq){
		if (!this._ResetOnStart && !this._Repeat){
			throw "One of ResetOnStart or Repeat must be true"
		}
		this._BuildSeq(seq)
		return this
	}
	
	Repeat(rpt){
		this._Repeat := rpt
		return this
	}
	
	ResetOnStart(rst){
		this._ResetOnStart := rst
		return this
	}
	
	SetTokenChars(open, close){
		tc := [open, close]
		Loop 2 {
			if (InStr(this._ForbiddenTokens, tc[A_Index])){
				throw "Invalid character used for Token: " tc[A_Index]
			}
			if (InStr(this._EscapeChars, tc[A_Index])){
				tc[A_Index] := "\" tc[A_Index]
			}
		}

		this._TokenChars := tc
		return this
	}
	
	Start(){
		OutputDebug % "AHK| Starting timer"
		if (this._ResetOnStart){
			this.Pos := 1
		}
		;~ this._Tick()
		if (this._SequenceActive)
			return
		this._Start()
		return this
	}
	
	Stop(){
		OutputDebug % "AHK| Stopping timer"
		if (!this._SequenceActive)
			return
		this._Stop()
		return this
	}
	
	Toggle(){
		if (this._SequenceActive)
			this.Stop()
		else
			this.Start()
	}
	
	Debug(dbg){
		this._Debug := dbg
		return this
	}
	
	BlindMode(blind){
		this._BlindMode := blind
		return this
	}
	
	_Start(){
		this._SequenceActive := 1
		fn := this.TickFn
		SetTimer, % fn, -0
	}
	
	_Stop(){
		this._SequenceActive := 0
		fn := this.TickFn
		SetTimer, % fn, Off
	}
	
	_Tick(){
		;~ OutputDebug % "AHK| Processing Pos " this.Pos
		if (!this._SequenceActive || this._Aborting){
			OutputDebug % "AHK| Repeat disabled, aborting..."
			this._Aborting := 0
			this._Stop()
			return
		}
		item := this._GetItem()
		n := item.TokenName
		
		atEnd := this.Pos >= this._Seq.Length()
		if (atEnd){
			if (this._Repeat){
				this.Pos := 0
			} else {
				OutputDebug % "AHK| Setting Aborting to true..."
				this._Aborting := 1
				;~ return
			}
		}
		this.Pos++
		item.Execute()
	}
	
	_GetItem(){
		return this._Seq[this.Pos]
	}
	
	_BuildSeq(SeqStr){
		this._Seq := this.__BuildSeq(SeqStr)
	}
	
	__BuildSeq(SeqStr){
		Seq := []
		
		inToken := 0
		inBrace := 0
		max := StrLen(SeqStr)
		str := ""
		chunks := []
		Loop % max {
			c := SubStr(SeqStr, A_Index, 1)
			if (c == "]")
				a := 1
			if (c == "{" && !inToken){
				str .= c
				inBrace := 1
			} else if (c == "}" && inBrace && !inToken){
				str .= c
				inBrace := 0
			} else if (c == "[" && !inToken && !inBrace){
				if (str != ""){
					chunks.Push(str)
					str := ""
				}
				str := c
				inToken := 1
			} else if (c == "]" && inToken && !inBrace){
				str .= c
				chunks.Push(str)
				str := ""
				inToken := 0
			} else {
				str .= c
			}
		}
		if (str != ""){
			chunks.Push(str)
		}
		
		for i, chunk in chunks {
			max := StrLen(chunk)
			if (SubStr(chunk, 1, 1) == "["){
				; Token
				tokenStr := SubStr(chunk, 2, max - 2)
				tc := this._SplitToken(tokenStr)
				
				if (this._TokenClasses.HasKey(tc[1])){
					cn := this._TokenClasses[tc[1]]
					cls := this._ClassLookup(cn)
					tc.RemoveAt(1)
					i := new cls(this, tc)
					if (i == ""){
						throw "Could not create class " cls
					}
					Seq.Push(i)
				}
			} else { 
				; Send String
				pos := 1
				while (pos){
					pos := RegexMatch(chunk, this._SendRgx, match, pos)
					if (pos == 0){
						break
					}
					s := match[1]
					Seq.Push(new DefaultTokens.SendObj(this, [s]))
					pos += match.Len
					if (pos > max)
						break
				}
			}
		}
		return Seq
	}
	
	; By nnik
	; https://www.autohotkey.com/boards/viewtopic.php?p=273269#p273269
	_ClassLookup(name) {
		Local _splitName, _branch, _branchName, _each ;defining the local variables will make the function assume global
		;it's not necessary but will prevent other super-globals from interfering with those values
		_splitName := StrSplit(name, ".") ;split up the string at the . to get the seperate parts of the name
		_branchName := _splitName.removeAt(1) ;get the first part - the name of the top-level parent class
		_branch := %_branchName% ;get the top-level parent class object
		for _each,_branchName in _splitName { ;the remaining parts of the name are nested classes
			_branch := ObjRawGet(_branch, _branchName) ;look up the nested class inside the current parent
		}
		return _branch ;finally return what we looked up
	}
	
	_SplitToken(tokenStr){
		ret := []
		pos := 1
		max := StrLen(tokenStr)
		while (pos){
			pos := RegExMatch(tokenStr, "O)([\w ]+)[,]?", match, pos)
			
			m := match[1]
			if (pos){
				pos += StrLen(m)
			} else {
				break
			}
			ret.Push(Trim(m))
			if (pos == max)
				break
		}
		return ret
	}
}
