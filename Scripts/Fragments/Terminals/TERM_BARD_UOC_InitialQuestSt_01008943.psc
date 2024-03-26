;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_BARD_UOC_InitialQuestSt_01008943 Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
InitialQuest.SetObjectiveCompleted(2)
InitialQuest.SetStage(25)

NewManager.ProcessPendingPackages()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property Manager Auto Const
BARD:OC:BARD_UOC_Manager Property NewManager Auto Const

Quest Property InitialQuest Auto Const
