class DefaultTokens {
	; Handles Send
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
			
			this.OnNext(0)	; Trigger next action
		}
	}

	; Used for Unit Tests
	class DummyToken extends BaseObjects.BaseTokenObj {
		Type := 2
		TokenName := "DummyToken"
	}
	
	; Handles Sleep
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

	; Handles RandSleep
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
			this.ParamStr := this.Join(" ", params)
		}
		
		Execute(){
			OutputDebug % "AHK| WinWaitActive: '" this.ParamStr "'"
			WinWaitActive % this.Params[1], % this.Params[2], % this.Params[3], % this.Params[4]
			this.OnNext(0)
		}
	}
	
	class WinWaitNotActive extends BaseObjects.BaseSleepObj {
		TokenName := "WinWaitNotActive"
		
		Build(params){
			this.ParamStr := this.Join(" ", params)
		}
		
		Execute(){
			OutputDebug % "AHK| WinWaitNotActive: '" this.ParamStr "'"
			WinWaitNotActive % this.Params[1], % this.Params[2], % this.Params[3], % this.Params[4]
			this.OnNext(0)
		}
	}
	
	class WinActivate extends BaseObjects.BaseTokenObj {
		TokenName := "WinActivate"
		
		Build(params){
			this.ParamStr := this.Join(", ", params)
		}
		
		Execute(){
			WinActivate, % this.Params[1], % this.Params[2], % this.Params[3], % this.Params[4]
			this.OnNext(0)
		}
	}
	
	class ControlSend extends BaseObjects.BaseTokenObj {
		TokenName := "ControlSend"
		
		Build(params){
			this.ParamStr := this.Join(", ", params)
		}
		
		Execute(){
			if (this.Parent._Debug){
				OutputDebug % "AHK| ControlSend: '" this.ParamStr "'"
			} else {
				ControlSend, % this.Params[1], % this.Params[2], % this.Params[3], % this.Params[4], % this.Params[5], % this.Params[6]
			}
			this.OnNext(0)
		}
	}
	
	class SetKeyDelay extends BaseObjects.BaseTokenObj {
		TokenName := "SetKeyDelay"
		
		Build(params){
			this.ParamStr := this.Join(", ", params)
		}
		
		Execute(){
			if (this.Parent._Debug){
				OutputDebug % "AHK| SetKeyDelay: '" this.ParamStr "'"
			} else {
				SetKeyDelay, % this.Params[1], % this.Params[2]
			}
			this.OnNext(0)
		}
	}
}
