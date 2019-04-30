class DefaultTokens {
	class SendObj extends BaseObjects.BaseObj {
		Type := 1
		SendStr := ""
		
		Build(params){
			this.SendStr := params[1]
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
		
		Build(params){
			this.SleepTime := params[1]
		}
		
		GetSleepTime(){
			return this.SleepTime
		}

	}

	class RandSleepObj extends BaseObjects.BaseSleepObj {
		TokenName := "RandSleep"
		MinSleep := 0
		MaxSleep := 0
		
		Build(params){
			this.MinSleep := params[1]
			this.MaxSleep := params[2]			
		}
		
		GetSleepTime(){
			Random, value, % this.MinSleep, % this.MaxSleep
			return value
		}
	}
	
	class WinWaitActive extends BaseObjects.BaseSleepObj {
		TokenName := "WinWaitActive"
		
		Build(params){
			this.WinTitle := ""
			max := params.Length()
			Loop % max {
				v := params[A_Index]
				this.WinTitle .= v
				if (A_Index != max)
					this.WinTitle .= " "
			}
		}
		
		Execute(){
			OutputDebug % "AHK| Waiting for '" this.WinTitle "' to be active..."
			WinWaitActive, % this.WinTitle
			this.OnNext()
		}
	}
}
