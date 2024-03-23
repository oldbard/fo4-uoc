Scriptname BARD:OC:BARD_LocatorsStarCorePackData extends BARD:OC:BARD_LocatorsPackData

GlobalVariable[] Property ObjectivesGlobal Auto

int[] Property ObjectivesGlobalID Auto

function ResolveReferences()
    parent.ResolveReferences()
    Trace("Resolving References on Star Core Pack")
    ObjectivesGlobal = new GlobalVariable[0]

    int i = 0
    while i < ObjectivesGlobalID.Length
        int globalID = ObjectivesGlobalID[i]
        GlobalVariable globalVar = Game.GetFormFromFile(globalID, RequiredDLC) as GlobalVariable
        ObjectivesGlobal.Add(globalVar)
        i += 1
    endWhile
endFunction

bool function CanCompleteObjective(QuestObjective objective)
    bool canComplete = parent.CanCompleteObjective(objective)

    if(!canComplete)
        Trace("CanCompleteObjective returned false")
        return false
    else
        GlobalVariable variable

        if(ObjectivesGlobal == NONE)
            Trace("ObjectivesGlobal == NONE at " + PackName)
            return true
        endif

        int i = 0
        while i < ObjectivesGlobal.Length
            if(ObjectivesGlobal[i].GetValue() > 0)
                Trace("Global has value " + ObjectivesGlobal[i].GetValue() + ". Cannot complete")
                return false
            endif
            i += 1
        endWhile
    endif

    Trace("Can complete!")
    return true
endFunction