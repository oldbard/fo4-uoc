Scriptname BARD:OC:BARD_UOC_PackData extends Quest

BARD:OC:BARD_UOC_Manager Property Manager Auto

String Property PackName Auto Const
Bool Property Respawnables = False Auto Const

struct QuestObjective
    int ID
    bool Completed
    bool DetectByDistance
    Form TargetForm
    int FormID
    Form InventoryForm
    int InventoryFormID
    ReferenceAlias Ref
endStruct

QuestObjective[] Property Objectives Auto

bool Property Processed = false Auto
bool Property Enabled = false Auto
bool Property Visible = true Auto

Actor Property PlayerReference Auto

GlobalVariable Property ClearedCellRespawnMultiplier Auto
GlobalVariable Property PA_DetectionRange Auto

String Property RequiredDLC Auto
String Property RequiredWorldSpace Auto

event OnQuestInit()
    Trace("Initiated Quest " + PackName)

    Utility.Wait(5)

    Manager.AddQueuedPackage(self)

;    if(CanBeInstalled())
;        LoadPackage()
;    endif
endEvent

function LoadPackage()
    QuestObjective objective
    int i = 0
    while i < Objectives.Length
        objective = Objectives[i]
        ResolveReference(objective)
        if(!TryCompleteObjective(objective))
            ResolveObjective(objective)
        endif
        i += 1
    endWhile

    EnablePack()
endFunction

function EnablePack()
    Trace("Enabling objectives of pack " + PackName)
    SetStage(20)

    RegisterForRemoteEvent(PlayerReference, "OnItemAdded")
    
    Enabled = true

    Start()
endFunction

function ResolveReference(QuestObjective objective)
    if(objective.TargetForm == NONE && objective.FormID > 0)
        objective.TargetForm = Game.GetFormFromFile(objective.FormID, RequiredDLC) as Form
        if(objective.TargetForm == NONE)
            Trace("ResolveReferences - Could not resolve TargetForm on " + objective.ID)
        endif
    endif
    if(objective.InventoryForm == NONE && objective.InventoryFormID > 0)
        objective.InventoryForm = Game.GetFormFromFile(objective.InventoryFormID, RequiredDLC) as Form
        if(objective.InventoryForm == NONE)
            Trace("ResolveReferences - Could not resolve InventoryForm on " + objective.ID)
        endif
    endif
endFunction

function RefreshReference(Cell curCell)
    QuestObjective objective = NONE

    int i = 0
    while i < Objectives.Length
        objective = Objectives[i]
        if(true)
            ObjectReference ref = objective.Ref.GetReference()
            Trace("Refreshing reference of " + ref + " at id " + objective.ID + " at " + PackName)
;            SetObjectiveDisplayed(objective.ID, PlayerReference.GetParentCell() == ref.GetParentCell())
            ;if(PlayerReference.GetParentCell() != ref.GetParentCell())

            ;endif
            ;objective.Ref.Clear();
            ;objective.Ref.ForceRefTo(ref)
        endif
        i += 1
    endWhile
endFunction

function ResolveObjective(QuestObjective objective)
    if(objective.TargetForm != NONE)
        objective.Ref.ForceRefTo(objective.TargetForm as ObjectReference)
        if(objective.DetectByDistance)
            SetupByDistance(objective)
        else
            SetupByPickup(objective)
        endif
        SetObjectiveDisplayed(objective.ID, true)
    else
        Trace("ERROR: TargetForm Was Not Resolved!")
    endif
endFunction

function SetupByDistance(QuestObjective objective)
    Trace("Setting up distance of " + PA_DetectionRange.GetValue() + " of object " + objective.TargetForm + " for objective " + objective.ID + " at pack " + PackName)
    RegisterForDistanceLessThanEvent(PlayerReference, objective.TargetForm, PA_DetectionRange.GetValue())
endFunction

function SetupByPickup(QuestObjective objective)
    if(objective.InventoryForm != NONE)
        AddInventoryEventFilter(objective.InventoryForm)
    else
        Trace("ERROR: InventoryForm Was Not Resolved!")
    endif
endFunction

; CONTROL

function CompleteObjective(QuestObjective objective)
    if(Respawnables)
        QueueReset(objective)
        SetObjectiveDisplayed(objective.ID, false)
    else
        Trace("CompleteObjective: " + objective.ID + " on " + PackName)
        objective.Completed = true
        SetObjectiveCompleted(objective.ID)
        SetObjectiveDisplayed(objective.ID, false)
        SetObjectiveCompleted(objective.ID)
        objective.Ref.Clear()
        int index = Objectives.Find(objective)
        if(index > -1)
            Objectives.Remove(index)
        endif
;        _locatorsManager.CompletedObjective(self, objective.ID)
    endif
endFunction

; END CONTROL

; UTILS

bool function CanBeInstalled(string currentWorldSpace)
    bool canBeInstalled = false
    if(RequiredDLC != "")
        canBeInstalled = Game.IsPluginInstalled(RequiredDLC)
        Trace("Requires DLC: " + RequiredDLC)
    endif

    if(RequiredWorldSpace != "")
        canBeInstalled = canBeInstalled && RequiredWorldSpace == currentWorldSpace
        Trace("Requires WorldSpace: " + RequiredWorldSpace)
    endif

    return canBeInstalled
endFunction

QuestObjective function GetObjective(int id)
    int index = Objectives.FindStruct("ID", id)

    if(index < 0)
        return NONE
    else
        return Objectives[index]
    endif
endFunction

bool function IsQuestCompleted()
    int i = 0
    while i < Objectives.Length
        QuestObjective objective = Objectives[i]
        if(!IsObjectiveCompleted(objective.ID))
            return false
        endif
        i += 1
    endWhile
    Trace("IsQuestCompleted - Quest Is Completed")
    return true
endFunction

QuestObjective function GetQuestObjectiveByForm(Form objRef)
    int index = Objectives.FindStruct("TargetForm", objRef)
    if(index >= 0)
        return Objectives[index]
    endif

    return NONE
endFunction

QuestObjective function GetQuestObjectiveByInventoryForm(Form objRef)
    int index = Objectives.FindStruct("InventoryForm", objRef)
    if(index >= 0)
        return Objectives[index]
    endif

    return NONE
endFunction

QuestObjective function GetQuestObjectiveByObjRef(ObjectReference objRef)
    QuestObjective objective
    
    int i = 0
    while(i < Objectives.Length)
        objective = Objectives[i]
        if(objective.Ref.GetReference() == objRef)
            return objective
        endif
        i += 1
    endWhile

    return NONE
endFunction

function QueueReset(QuestObjective objective)
    float multiplier = ClearedCellRespawnMultiplier.GetValue()

    int hoursToRespawn = Game.GetGameSettingInt("iHoursToRespawnCellCleared")

    float timerValue = (hoursToRespawn + 4) * multiplier

    Trace("Time To Respawn: " + hoursToRespawn + ". Time to Respawn in seconds with buffer: " + timerValue)
    StartTimerGameTime(timerValue, objective.ID)
endFunction

bool function PlayerOwnsObjective(QuestObjective objective)
    return objective.InventoryForm != NONE && PlayerReference.GetItemCount(objective.InventoryForm) > 0

    return false
endFunction

bool function CanCompleteObjective(QuestObjective objective)
    return PlayerOwnsObjective(objective)
endFunction

bool function TryCompleteObjective(QuestObjective objective)
    if(CanCompleteObjective(objective))
        if(!IsObjectiveCompleted(objective.ID))
            CompleteObjective(objective)
        endif

        if(IsQuestCompleted())
            Trace("LoadPackData - Quest is completed! " + PackName)
            CompleteQuest()
            RemoveInventoryEventFilter(objective.InventoryForm)
            Processed = true
        endif
        return true
    endif

    return false
endFunction

; END UTILS

; CALLBACKS

event ObjectReference.OnItemAdded(ObjectReference oPlayer, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Trace("OnItemAdded - Object Collected: " + akItemReference.GetFormID())
    if !akSourceContainer || akSourceContainer != PlayerReference
        QuestObjective objective = GetQuestObjectiveByInventoryForm(akBaseItem)
        if(objective != NONE)
            CompleteObjective(objective)
            RemoveInventoryEventFilter(akBaseItem)
        else
            Trace("OnItemAdded - Could not find Objective")
        endif

        if(IsQuestCompleted())
            Trace("OnItemAdded - Quest is completed! " + akItemReference)
            UnregisterForRemoteEvent(PlayerReference, "OnItemAdded")
            CompleteQuest()
            RemoveInventoryEventFilter(akBaseItem)
        endif
    endif
endEvent

event OnDistanceLessThan(ObjectReference player, ObjectReference objRef, float distance)
    Trace("OnDistanceLessThan: " + objRef.GetDisplayName())
    QuestObjective objective = GetQuestObjectiveByObjRef(objRef)
    if(objective != NONE)
        Trace("Completed Objective: " + objective.ID + " at " + PackName)
        CompleteObjective(objective)

        if(!Respawnables && IsQuestCompleted())
            Trace("OnDistanceLessThan - Quest is completed! " + objRef)
            CompleteQuest()
        endif
    else
        Trace("Could not find reference for ObjRef: " + objRef.GetDisplayName())
    endif
endEvent

event OnTimerGameTime(int id)
    if(Respawnables)
        Trace("Timer completed for objective: " + id + " Setting Objective Displayed again.")
        QuestObjective objective = GetObjective(id)

        if(objective == NONE)
            Trace("Could not find the objective at OnTimerGameTime. This should not be possible!")
        else
            SetupByDistance(objective)
            SetObjectiveDisplayed(id, true, true)
        endif
    endif
endEvent

; END CALLBACKS

bool function Trace(string asTextToPrint, int aiSeverity = 0) debugOnly
	string logName = "BARD_ObjectsLocator"
	Debug.OpenUserLog(logName)
	return Debug.TraceUser(logName, "UOC-PackData: " + asTextToPrint, aiSeverity)
endFunction