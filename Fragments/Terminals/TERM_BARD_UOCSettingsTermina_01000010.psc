;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_BARD_UOCSettingsTermina_01000010 Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
BARD:OC:BARD_LocatorsManager locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
DistanceDetectionEnabled.SetValue(1)
locatorsManager.EnableDistanceDetection()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property Manager Auto Const

GlobalVariable Property DistanceDetectionEnabled Auto Const
