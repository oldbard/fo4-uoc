;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_BARD_UOC_InitialQuestSt_01008940 Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
InitialQuest.SetObjectiveCompleted(2)
InitialQuest.SetStage(25)

BARD:OC:BARD_LocatorsManager locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
locatorsManager.InitPackageLoading()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property Manager Auto Const

Quest Property InitialQuest Auto Const