class DefaultTokens {
	class BaseObj {
		HasDelay := 0
		__New(parent, tokenStr){
			this.Parent := parent
			this.Build(tokenStr)
			this.RawText := tokenStr
		}
	}


	class BaseTokenObj extends DefaultTokens.BaseObj {
		Type := 2
		HasDelay := 0
		TokenName := ""
	}

	class SendObj extends DefaultTokens.BaseObj {
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

	class BaseSleepObj extends DefaultTokens.BaseTokenObj {
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

	class SleepObj extends DefaultTokens.BaseSleepObj {
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

	class RandSleepObj extends DefaultTokens.BaseSleepObj {
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
