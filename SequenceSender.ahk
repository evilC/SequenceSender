class SequenceSender {
	Pos := 1
	_Aborting := 0
	_TimerRunning := 0
	_Repeat := true
	_ResetOnStart := true
	_Seq := []
	_TokenChars := ["\[", "\]"]
	_EscapeChars := "[\^$.|?*+()"	; If Tokens use one of these chars, they need to be escaped with \ for the regex
	_ForbiddenTokens := "{}<>"			; Do not allow these characters for token delimiters
	_SeqTypeToName := ["Send", "Sleep", "RandSleep"]
	_SeqNameToType := {}
	_Debug := false
	_BlindMode := 0
	
	__New(){
		this.TickFn := this._Tick.Bind(this)
		for i, v in this._SeqTypeToName {
			this._SeqNameToType[v] := i
		}
	}
	
	Load(seq){
		if (!this._ResetOnStart && !this._Repeat){
			throw "One of ResetOnStart or Repeat must be true"
		}
		this.SeqStr := seq
		this._BuildSeq()
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
		fn := this.TickFn
		SetTimer, % fn, % "-" t
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
	
	_BuildSeq(){
		this._Seq := []
		pos := 1
		matches := []
		/*
		([\^|+|!|$|#]*({\w+}|\w{1}))
		Capture Send strings
		Matches OPTIONAL modifier (^+!#) PLUS...
		... EITHER { <any number of chars> }
		... OR <single char>
		eg
		^c
		^{a}
		{Space}
		
		\[([\w| |,]+)\]
		Capture Tokens
		Delimiters are [ and ] by default, but can be changed
		Matches [ <any number of chars> ]
		eg
		[Sleep 100]
		[RandSleep 10, 100]
		*/
		rgx := "O)([\^|+|!|#|<|>]*({\w+}|\w{1}))|" this._TokenChars[1] "([\w| |,]+)" this._TokenChars[2]
		
		while (pos){
			;~ pos := RegexMatch(this.SeqStr, "OU)([\^|!|$|#]*{.+})|\[(.+)\]+", match, pos)
			pos := RegexMatch(this.SeqStr, rgx, match, pos)
			c := match.Count
			ss := match[1]
			s := Trim(match[1])
			if (s != ""){
				this._Seq.Push(new this.SendObj(this, this._SeqNameToType.Send, s))
				pos += StrLen(s)
			}
			x := Trim(match[2])
			
			t := Trim(match[3])
			if (t != ""){
				if (InStr(t, "randsleep")){
					type := this._SeqNameToType.RandSleep
					this._Seq.Push(new this.RandSleepObj(this, type, t))
				} else if (InStr(t, "sleep")){
					type := this._SeqNameToType.Sleep
					this._Seq.Push(new this.SleepObj(this, type, t))
				}
				
				pos += StrLen(t) + 2 ; Add 2 to include [] token delimiters
			}
		}
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
