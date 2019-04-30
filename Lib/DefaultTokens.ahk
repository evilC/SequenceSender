class DefaultTokens {
	class SendObj extends BaseObjects.BaseObj {
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
			
			this.OnNext()
		}
	}

	class SleepObj extends BaseObjects.BaseSleepObj {
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

	class RandSleepObj extends BaseObjects.BaseSleepObj {
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
	
	class WinWaitActive extends BaseObjects.BaseSleepObj {
		TokenName := "WinWaitActive"
		
		Execute(){
			OutputDebug % "AHK| Waiting for '" this.RawText "' to be active..."
			WinWaitActive, % this.RawText
			this.OnNext()
		}
	}
}
