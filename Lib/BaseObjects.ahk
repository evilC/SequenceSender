class BaseObjects {
	class BaseObj {
		HasDelay := 0
		__New(parent, tokenStr){
			this.Parent := parent
			this.Build(tokenStr)
			this.RawText := tokenStr
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
			;~ fn := this.Parent._Tick.Bind(this.Parent)
			fn := this.Parent.TickFn
			t := this.GetSleepTime()
			if (this.Parent._Debug){
				OutputDebug, % "AHK| Sleeping for " t " @ " A_TickCount
			}
			SetTimer, % fn, % "-" t
		}
	}
}
