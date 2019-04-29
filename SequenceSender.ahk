class SequenceSender {
	Pos := 1
	_Aborting := 0
	_TimerRunning := 0
	_Repeat := true
	_ResetOnStart := true
	_Seq := []
	_Mods := "+^!#<>"
	_TokenRgx := "OU)(\[.+\])"
	_SeqTypeToName := ["Send", "Sleep", "RandSleep"]
	_SeqNameToType := {}
	_Debug := false
	_BlindMode := 0
	
	__New(){
		this._SendRgx := "OU)([" this._Mods "]*({.+}|[^" this._Mods "]))"
		this._TickFn := this._Tick.Bind(this)
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
		this._Stop()
		return this
	}
	
	Debug(dbg){
		this._Debug := dbg
		return this
	}
	
	BlindMode(blind){
		this._BlindMode := blind
		return this
	}
	
	_Start(t := 0){
		this._TimerRunning := 1
		fn := this._TickFn
		SetTimer, % fn, % "-" t
	}
	
	_Stop(){
		this._TimerRunning := 0
		fn := this._TickFn
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
		if (item.HasDelay){
			t := item.GetSleepTime()
			if (this._Debug)
				OutputDebug, % "AHK| Sleeping for " t " @ " A_TickCount
			this._Start(t)
		} else {
			item.Execute()
			this._Start()
		}
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
				t := SubStr(chunk, 2, max - 2)
				if (InStr(t, "randsleep")){
					type := this._SeqNameToType.RandSleep
					Seq.Push(new this.RandSleepObj(this, type, t))
				} else if (InStr(t, "sleep")){
					type := this._SeqNameToType.Sleep
					Seq.Push(new this.SleepObj(this, type, t))
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
					Seq.Push(new this.SendObj(this, this._SeqNameToType.Send, s))
					pos += match.Len
					if (pos > max)
						break
				}
			}
		}
		return Seq
	}
	
	class BaseObj {
		HasDelay := 0
		__New(parent, type, rawText){
			this.Parent := parent
			this.Type := type
			this.RawText := rawText
			this.Build()
		}
	}

	class SendObj extends SequenceSender.BaseObj {
		SendStr := ""
		
		__New(parent, type, rawText){
			base.__New(parent, type, rawText)
		}
		
		Build(){
			this.SendStr := this.rawText
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
		}
	}
	
	class BaseSleepObj extends SequenceSender.BaseObj {
		HasDelay := 1
		__New(parent, type, text){
			base.__New(parent, type, text)
		}
		
		Execute(){

		}
	}

	class SleepObj extends SequenceSender.BaseSleepObj {
		SleepTime := 0
		__New(parent, type, rawText){
			base.__New(parent, type, rawText)
		}
		
		Build(){
			pos := RegExMatch(this.rawText, "iO)sleep (\d+)", match)
			if (!pos){
				throw new Exception("Unknown token " this.rawText)
			}
			this.SleepTime := match[1]
		}
		
		GetSleepTime(){
			return this.SleepTime
		}
	
	}
	
	class RandSleepObj extends SequenceSender.BaseSleepObj {
		MinSleep := 0
		MaxSleep := 0
		
		__New(parent, type, rawText){
			base.__New(parent, type, rawText)
		}
		
		Build(){
			pos := RegExMatch(this.rawText, "iO)randsleep (\d+)[ ]*,[ ]*(\d+)", match)
			if (!pos || match[1] == "" || match[2] == ""){
				throw new Exception("Bad format: " this.rawText)
			}
			this.MinSleep := match[1]
			this.MaxSleep := match[2]
		}
		
		GetSleepTime(){
			Random, value, % this.MinSleep, % this.MaxSleep
			return value
		}
	}
}
