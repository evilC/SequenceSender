class BaseObjects {
	class BaseObj {
		HasDelay := 0
		__New(parent, tokenStr){
			this.Parent := parent
			this.Build(tokenStr)
			this.RawText := tokenStr
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
		__New(parent, tokenStr){
			base.__New(parent, tokenStr)
		}
		
		Execute(){
			t := this.GetSleepTime()
			if (this.Parent._Debug){
				OutputDebug, % "AHK| Sleeping for " t " @ " A_TickCount
			}
			this.OnNext(t)
		}
	}
}
