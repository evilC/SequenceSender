class BaseObjects {
	class BaseObj {
		HasDelay := 0
		__New(parent, params){
			this.Parent := parent
			this.Params := params
			this.Build(params)
			;~ this.RawText := tokenStr
		}
		
		OnNext(t := 0){
			fn := this.Parent.TickFn
			SetTimer, % fn, % "-" t			
		}
	}

	class BaseTokenObj extends BaseObjects.BaseObj {
		Type := 2
		HasDelay := 0
		TokenName := ""
	}
	
	class BaseSleepObj extends BaseObjects.BaseTokenObj {
		HasDelay := 1
		;~ __New(parent, params){
			;~ base.__New(parent, params)
		;~ }
		
		Execute(){
			t := this.GetSleepTime()
			if (this.Parent._Debug){
				OutputDebug, % "AHK| Sleeping for " t " @ " A_TickCount
			}
			this.OnNext(t)
		}
	}
}
