;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_BARD_UOCSettingsTermina_0100000F Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
DetectionRange.SetValue(1500.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
DetectionRange.SetValue(3000.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
DetectionRange.SetValue(1000.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
DetectionMinRange.SetValue(35000)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
DetectionMinRange.SetValue(45000)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
DetectionMinRange.SetValue(30000)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
DetectionMaxRange.SetValue(55000)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
DetectionMaxRange.SetValue(65000)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
DetectionMaxRange.SetValue(50000)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_10
Function Fragment_Terminal_10(ObjectReference akTerminalRef)
;BEGIN CODE
EnableDebugMenu.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_11
Function Fragment_Terminal_11(ObjectReference akTerminalRef)
;BEGIN CODE
DetectionMinRange.SetValue(30000)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_12
Function Fragment_Terminal_12(ObjectReference akTerminalRef)
;BEGIN CODE
EnableDebugMenu.SetValue(0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property Manager Auto Const

GlobalVariable Property DetectionRange Auto Const

GlobalVariable Property DetectionMinRange Auto Const

GlobalVariable Property DetectionMaxRange Auto Const

GlobalVariable Property EnableDebugMenu Auto Const
