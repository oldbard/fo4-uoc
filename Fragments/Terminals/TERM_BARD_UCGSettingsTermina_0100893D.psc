;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_BARD_UCGSettingsTermina_0100893D Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
BARD:OC:BARD_LocatorsManager locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
LeveledPAs.SetValue(1.0)
locatorsManager.TogglePackage(13, true)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
BARD:OC:BARD_LocatorsManager locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
LeveledPAs.SetValue(0.0)
locatorsManager.TogglePackage(13, false)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
BARD:OC:BARD_LocatorsManager locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
FixedPAs.SetValue(1.0)
locatorsManager.TogglePackage(14, true)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
BARD:OC:BARD_LocatorsManager locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
FixedPAs.SetValue(0.0)
locatorsManager.TogglePackage(14, false)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
BARD:OC:BARD_LocatorsManager locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
RespawnablePAs.SetValue(1.0)
locatorsManager.TogglePackage(15, true)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
BARD:OC:BARD_LocatorsManager locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
RespawnablePAs.SetValue(0.0)
locatorsManager.TogglePackage(15, false)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property Manager Auto Const

GlobalVariable Property LeveledPAs Auto Const

GlobalVariable Property FixedPAs Auto Const

GlobalVariable Property RespawnablePAs Auto Const
