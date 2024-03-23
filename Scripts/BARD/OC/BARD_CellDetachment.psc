Scriptname BARD:OC:BARD_CellDetachment extends ObjectReference Const

ObjectReference Property PlayerReference Auto Const

Quest Property Manager Auto Const

Message Property AliasName Auto Const

event OnCellDetach()
    Utility.Wait(0.1)
    MoveTo(PlayerReference)
    (Manager as BARD:OC:BARD_LocatorsManager).OnCellChanged()
    ReferenceAlias aliasTest = NONE
endEvent

bool function Trace(string asTextToPrint, int aiSeverity = 0) debugOnly
	string logName = "BARD_ObjectsLocator"
	Debug.OpenUserLog(logName)
	return Debug.TraceUser(logName, "CellDetachment: " + asTextToPrint, aiSeverity)
endFunction