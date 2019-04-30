class SequenceSender {
	Pos := 1
	_Aborting := 0
	_TimerRunning := 0
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
	_TokenClasses := {Sleep : "SequenceSender.SleepObj", RandSleep: "SequenceSender.RandSleepObj"}
	
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
		if (this._TimerRunning)
			return
		this._Start()
		return this
	}
	
	Stop(){
		OutputDebug % "AHK| Stopping timer"
		if (!this._TimerRunning)
			return
		this._Stop()
		return this
	}
	
	Toggle(){
		if (this._TimerRunning)
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
		this._TimerRunning := 1
		fn := this.TickFn
		SetTimer, % fn, -0
	}
	
	_Stop(){
		this._TimerRunning := 0
		fn := this.TickFn
		SetTimer, % fn, Off
	}
	
	_Tick(){
		;~ OutputDebug % "AHK| Processing Pos " this.Pos
		if (!this._TimerRunning || this._Aborting){
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
		chunks := []
		pos := 1
		while (pos){
			pos := RegexMatch(SeqStr, this._TokenRgx, match, pos)

			if (pos == 0){
				chunks.Push(SeqStr)
				break
			} else if (pos > 1){
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
				tc := this._SplitToken(tokenStr)
				
				if (this._TokenClasses.HasKey(tc[1])){
					cn := this._TokenClasses[tc[1]]
					cls := this._ClassLookup(cn)
					i := new cls(this, tc[2])
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
					Seq.Push(new this.SendObj(this, s))
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
		sp := InStr(tokenStr, " ")
		if (!sp)
			return [tokenStr]
		ret[1] := Trim(SubStr(tokenStr, 1, sp))
		ret[2] := Trim(SubStr(tokenStr, sp))
		return ret
	}
	
	class BaseObj {
		HasDelay := 0
		__New(parent, tokenStr){
			this.Parent := parent
			this.Build(tokenStr)
			this.RawText := tokenStr
		}
	}

	class TestClass {
		__New(p){
			a := 1
		}
	}
	
	class BaseTokenObj extends SequenceSender.BaseObj {
		Type := 2
		HasDelay := 0
		TokenName := ""
	}
	
	class SendObj extends SequenceSender.BaseObj {
		Type := 1
		SendStr := ""
		
		Build(tokenStr){
			this.SendStr := tokenStr
		}
		
		Execute(){
			str := this.SendStr
			if (this.Parent._BlindMode){
				str := "{Blind}" str
			}
			if (this.Parent._Debug){
				OutputDebug, % "AHK| Sending: " str " @ " A_TickCount
			} else {
				Send % str
			}
			
			fn := this.Parent.TickFn
			SetTimer, % fn, -0
		}
	}
	
	class BaseSleepObj extends SequenceSender.BaseTokenObj {
		HasDelay := 1
		__New(parent, tokenStr){
			base.__New(parent, tokenStr)
		}
		
		Execute(){
			;~ fn := this.Parent._Tick.Bind(this.Parent)
			fn := this.Parent.TickFn
			t := this.GetSleepTime()
			if (this.Parent._Debug){
				OutputDebug, % "AHK| Sleeping for " t " @ " A_TickCount
			}
			SetTimer, % fn, % "-" t
		}
	}

	class SleepObj extends SequenceSender.BaseSleepObj {
		SleepTime := 0
		TokenName := "Sleep"
		
		__New(parent, tokenStr){
			base.__New(parent, tokenStr)
		}
		
		Build(tokenStr){
			this.SleepTime := tokenStr
		}
		
		GetSleepTime(){
			return this.SleepTime
		}

	}

	class RandSleepObj extends SequenceSender.BaseSleepObj {
		TokenName := "RandSleep"
		MinSleep := 0
		MaxSleep := 0
		
		__New(parent, tokenStr){
			base.__New(parent, tokenStr)
		}
		
		Build(tokenStr){
			chunks := StrSplit(tokenStr, ",")
			if (chunks.Length() != 2){
				throw new Exception("Invalid format for RandSleep: " tokenStr)
			}
			this.MinSleep := Trim(chunks[1])
			this.MaxSleep := Trim(chunks[2])
		}
		
		GetSleepTime(){
			Random, value, % this.MinSleep, % this.MaxSleep
			return value
		}
	}
}
