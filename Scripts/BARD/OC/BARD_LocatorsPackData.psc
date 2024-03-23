Scriptname BARD:OC:BARD_LocatorsPackData extends Quest

int StateNone = 0 const
int StatePlaceholder = 1 const
int StateTarget = 2 const
int StateCompleted = 3 const

Quest Property Manager Auto Const

MiscObject Property ObjectivePlaceholder Auto Const
GlobalVariable Property PA_DetectionRange Auto Const
Keyword Property PA_Keyword Auto Const

Bool Property Respawnables = False Auto Const
String Property PackName Auto Const
ObjectReference _testPlaceholder

int Property InstituteObjectiveID = -1 Auto Const

String Property WorldSpaceName = "Commonwealth" Auto Const

String Property RequiredDLC Auto Const

struct QuestObjective
    int ID
    int CurrentTarget = -1
    int CurrentState
    float DetectionDistance
    ReferenceAlias AliasReference
    ObjectReference PlaceHolder
endStruct

struct ObjectiveTarget
    int ObjectiveID
    int Order
    float X
    float Y
    float Z
    bool Interior
    bool PowerArmor
    bool Resolved
    bool OnlyInProperCell
    Cell TargetCell
    int TargetCellID
    Form FormID
    int FormIDValue
    bool DirectRef
    Form SecondaryFormID ; In case we are checking for a respawn of an enemy
endStruct

struct ObjectiveQuestRequirement
    int ObjectiveID
    Quest ReqQuest
    bool HigherThan = true
    bool CompleteOnFail
    int Stage
endStruct

QuestObjective[] Property Objectives Auto
ObjectiveTarget[] Property ObjectivesTargets Auto
ObjectiveQuestRequirement[] Property ObjectivesRequirements Auto

Cell Property InstituteCell Auto

bool Property Processed = false Auto
bool Property Enabled = false Auto
bool Property Visible = true Auto

bool Property KeepInvFilterUntilComplete = false Auto

Actor _playerReference
BARD:OC:BARD_LocatorsManager _locatorsManager

event OnQuestInit()
    Trace("Initiated Quest " + PackName)
    _locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
    _playerReference = Game.GetPlayer()
endEvent

; HELPERS

bool function PlayerOwnsObjective(QuestObjective objective)
    ObjectiveTarget target = GetFirstTarget(objective.ID, ObjectivesTargets)

    return _playerReference.GetItemCount(target.FormID) > 0

    return false
endFunction

bool function CanCompleteByRequirement(QuestObjective objective)
    ObjectiveQuestRequirement req = GetRequirementByID(objective.ID)

    if(req == NONE)
        return false
    endif

    Trace("Verifying Requirement " + req.ObjectiveID + " on " + PackName)

    if(!CanDisplayObjective(req))
        return req.CompleteOnFail
    endif

    return false
endFunction

bool function CanDisplayObjective(ObjectiveQuestRequirement req)
    if(req == NONE)
        return true
    endif

    if(req.HigherThan)
        return req.ReqQuest.GetStage() > req.Stage
    else
        return req.ReqQuest.GetStage() <= req.Stage
    endif
endFunction
;/
bool function CanDisplayObjectiveById(int id)
    QuestObjective objective = GetObjective(id)

    return CanDisplayObjective(objective)
endFunction

;/
function RegisterQuestsRequirements()
    Quest[] processedQuests = new Quest[0]

    int i = 0
    while i < ObjectivesRequirements.Length
        ObjectiveQuestRequirement req = ObjectivesRequirements[i]
        if(processedQuests.Find(req.ReqQuest) < 0)
            processedQuests.Add(req.ReqQuest)
            RegisterForRemoteEvent(req.ReqQuest, "OnStageSet")
        endif
        i += 1
    endWhile
endFunction/;

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

function TraceAllTargets()
    ObjectiveTarget target
    int i = 0
    while i < ObjectivesTargets.Length
        target = ObjectivesTargets[i]
        Trace("Objective Target: " + target.ObjectiveID + ", with order: " + target.Order + " and data: " + target.FormID.GetName())
        i += 1
    endWhile
endFunction

; END HELPERS

; PROCESS

function LoadPackData()
    SetActive()
    SetStage(10)

    Trace("LoadPackData - Processing " + Objectives.Length + " objectives for Pack Data " + PackName)

    ResolveReferences()

    int i = 0

    while i < Objectives.Length
        QuestObjective objective = Objectives[i]
        if(TryCompleteObjective(objective))
            if(Processed)
                return
            endif

            if(Respawnables)
                i += 1
            endif
        else
            ResolveObjectiveTargets(objective)
            i += 1
        endif
    endWhile

    Processed = true
endFunction

function CheckRemoveInventoryFilter(QuestObjective objective)
    if(KeepInvFilterUntilComplete)
        ObjectiveTarget target = GetFirstTarget(objective.ID, ObjectivesTargets)
        RemoveInventoryEventFilter(target.FormID)
    endif
endFunction

bool function CanCompleteObjective(QuestObjective objective)
    return PlayerOwnsObjective(objective) || CanCompleteByRequirement(objective)
endFunction

bool function TryCompleteObjective(QuestObjective objective)
    if(CanCompleteObjective(objective))
        if(!IsObjectiveCompleted(objective.ID))
            CompleteObjective(objective)
        endif

        if(IsQuestCompleted())
            Trace("LoadPackData - Quest is completed! " + PackName)
            CompleteQuest()
            CheckRemoveInventoryFilter(objective)
            Processed = true
        endif
        return true
    endif

    return false
endFunction

function ResolveReferences()
    ObjectiveTarget target
    int i = 0
    while i < ObjectivesTargets.Length
        target = ObjectivesTargets[i]
        if(target.TargetCell == NONE && target.TargetCellID > 0)
            target.TargetCell = Game.GetFormFromFile(target.TargetCellID, RequiredDLC) as Cell
            if(target.TargetCell == NONE)
                Trace("ResolveReferences - Could not resolve TargetCell")
            endif
        endif
        if(target.FormID == NONE && target.FormIDValue > 0)
            target.FormID = Game.GetFormFromFile(target.FormIDValue, RequiredDLC) as Form
            if(target.FormID == NONE)
                Trace("ResolveReferences - Could not resolve FormID")
            endif
        endif
        i += 1
    endWhile
endFunction

function EnablePack()
    Trace("EnablePack - Enabling objectives of pack " + PackName)
    SetStage(20)

    RegisterForRemoteEvent(_playerReference, "OnItemAdded")

    Enabled = true

    Start()
endFunction

function DisablePack()
    SetStage(10)

    QuestObjective objective = NONE
    ObjectiveTarget target = NONE
    int i = Objectives.Length - 1
    while i > -1
        objective = Objectives[i]
        CancelTimerGameTime(objective.ID)

        if(!IsObjectiveCompleted(objective.ID))
            SetObjectiveDisplayed(objective.ID, false)

            target = GetFirstTarget(objective.ID, ObjectivesTargets)
            if(target != NONE)
                if(target.PowerArmor || objective.DetectionDistance > 0)
                    UnregisterForDistanceEvents(_playerReference, objective.AliasReference.GetReference())
                else
                    if(!IsObjectiveCompleted(objective.ID))
                        RemoveInventoryEventFilter(target.FormID)
                    endif
                endif
            endif
        endif
        
        if(objective.Placeholder != NONE)
            objective.Placeholder.Disable()
            objective.Placeholder.Delete()
            objective.Placeholder = NONE
        endif
        i -= 1
    endWhile
        
    UnregisterForRemoteEvent(_playerReference, "OnItemAdded")
    UnregisterForAllEvents()
    if(_testPlaceholder != NONE)
        _testPlaceholder.Disable()
        _testPlaceholder.Delete()
        _testPlaceholder = NONE
    endif

    _playerReference = NONE
    _locatorsManager = NONE
endFunction

function ShowPack()
    QuestObjective objective = NONE
    ObjectiveTarget target = NONE
    Visible = true

    int i = 0
    while i < Objectives.Length
        objective = Objectives[i]
        if(TryCompleteObjective(objective))
            if(IsQuestCompleted())
                return
            endif
        else
            target = GetTargetByOrder(objective.ID, objective.CurrentTarget, ObjectivesTargets)
            SetObjectiveDisplayed(objective.ID, true)
            
            target = GetFirstTarget(objective.ID, ObjectivesTargets)
            if(target != NONE)
                if(target.PowerArmor || objective.DetectionDistance > 0)
                    ObjectReference ref = objective.AliasReference.GetReference()
                    if(ref != NONE)
                        SetupPowerArmor(objective, objective.AliasReference.GetReference(), target)
                    endif
                else
                    AddInventoryEventFilter(target.FormID)
                endif
            endif
        endif
        i += 1
    endWhile

    RegisterForRemoteEvent(_playerReference, "OnItemAdded")
endFunction

function HidePack()
    QuestObjective objective = NONE
    ObjectiveTarget target = NONE
    Visible = false

    int i = 0
    while i < Objectives.Length
        objective = Objectives[i]
        SetObjectiveDisplayed(objective.ID, false)

        target = GetFirstTarget(objective.ID, ObjectivesTargets)
        if(target != NONE)
            if(target.PowerArmor || objective.DetectionDistance > 0)
                ObjectReference ref = objective.AliasReference.GetReference()
                if(ref != NONE)
                    UnregisterForDistanceEvents(_playerReference, objective.AliasReference.GetReference())
                endif
            else
                RemoveInventoryEventFilter(target.FormID)
            endif
        endif
        i += 1
    endWhile

    UnregisterForRemoteEvent(_playerReference, "OnItemAdded")
    UnregisterForAllEvents()
endFunction
;/
function CleanRequirements()
    int i = 0
    while i < ObjectivesRequirements.Length
        ObjectiveQuestRequirement req = ObjectivesRequirements[i]
        Quest q = req.ReqQuest
        if(q.GetStage() > req.Stage)
            ObjectivesRequirements.Remove(i)
            if(TotalRequirementsForQuest(q) < 1)
                UnregisterForRemoteEvent(q, "OnStageSet")
            endif
        else
            i += 1
        endif
    endWhile
endFunction

int function TotalRequirementsForQuest(Quest q)
    int total = 0

    int i = 0
    while i < ObjectivesRequirements.Length
        if(ObjectivesRequirements[i].ReqQuest == q)
            total += 1
        endif
        i += 1
    endWhile

    return total
endFunction
/;
function QueueReset(QuestObjective objective)
    float multiplier = _locatorsManager.ClearedCellRespawnMultiplier.GetValue()

    int hoursToRespawn = Game.GetGameSettingInt("iHoursToRespawnCellCleared")

    float timerValue = (hoursToRespawn + 4) * multiplier

    Trace("Time To Respawn: " + hoursToRespawn + ". Time to Respawn in seconds with buffer: " + timerValue)
    StartTimerGameTime(timerValue, objective.ID)
endFunction

event OnTimerGameTime(int id)
    if(Respawnables)
        Trace("Timer completed for objective: " + id + " Setting Objective Displayed again.")
        ObjectiveTarget target = GetFirstTarget(id, ObjectivesTargets)
        QuestObjective objective = GetObjective(id)

        if(target == NONE || objective == NONE)
            Trace("Could not find the target at OnTimerGameTime. This should not be possible!")
        else
            SetupPowerArmor(objective, objective.AliasReference.GetReference(), target)
            SetObjectiveDisplayed(id, true, true)
        endif
    endif
endEvent

function CompleteObjective(QuestObjective objective)
    if(Respawnables)
        QueueReset(objective)
        SetObjectiveDisplayed(objective.ID, false)
    else
        Trace("CompleteObjective: " + objective.ID + " on " + PackName)
        objective.CurrentState = StateCompleted
        SetObjectiveCompleted(objective.ID)
        SetObjectiveDisplayed(objective.ID, false)
        SetObjectiveCompleted(objective.ID)
        objective.AliasReference.Clear()
        if(objective.PlaceHolder != NONE)
            objective.PlaceHolder.Delete()
        endif
        int index = Objectives.Find(objective)
        if(index > -1)
            Objectives.Remove(index)
        endif
        _locatorsManager.CompletedObjective(self, objective.ID)
    endif
endFunction

; END PROCESS

; CONTROL

QuestObjective function GetQuestObjectiveByForm(Form objRef)
    int index = ObjectivesTargets.FindStruct("FormID", objRef)
    if(index >= 0)
        int objIndex = Objectives.FindStruct("ID", ObjectivesTargets[index].ObjectiveID)
        return Objectives[objIndex]
    endif

    return NONE
endFunction

QuestObjective function GetQuestObjectiveByObjRef(ObjectReference objRef)
    QuestObjective objective
    
    int i = 0
    while(i < Objectives.Length)
        objective = Objectives[i]
        if(objective.AliasReference.GetReference() == objRef || objective.PlaceHolder == objRef)
            return objective
        endif
        i += 1
    endWhile

    return NONE
endFunction

ObjectiveQuestRequirement function GetRequirementByID(int id)
    int index = ObjectivesRequirements.FindStruct("ObjectiveID", id)
    if(index > -1)
        return ObjectivesRequirements[index]
    endif

    return NONE
endFunction

bool function ObjectiveGotDefinitiveTarget(QuestObjective objective)
    if (objective.CurrentTarget != 0)
        return false
    endif
    return objective.CurrentTarget == 0 && objective.CurrentState == StateTarget
endFunction

function MoveToNextObjective(int jumpTo)
    QuestObjective objective = GetFirstNotCompletedObjective(jumpTo)
    if(objective != NONE)
        Trace("MoveToNextObjective - Moving Player to " + objective.AliasReference)
        _playerReference.MoveTo(objective.AliasReference.GetReference())
    else
        Trace("MoveToNextObjective - No objectives were found")
    endif
endFunction

function CompleteNextObjective(int jumpTo)
    QuestObjective objective = GetFirstNotCompletedObjective(jumpTo)
    if(objective != NONE)
        Trace("CompleteNextObjective - Completed objective for " + objective.AliasReference)
        CompleteObjective(objective)
    else
        Trace("CompleteNextObjective - No objectives were found")
    endif
endFunction

QuestObjective function GetFirstNotCompletedObjective(int jumpTo)
    int i = jumpTo
    while i < Objectives.Length
        QuestObjective objective = Objectives[i]
        if(!IsObjectiveCompleted(objective.ID))
            Trace("GetFirstNotCompletedObjective - Found an objective which is not completed: " + objective.AliasReference)
            return objective
        endif
        i += 1
    endWhile
    Trace("GetFirstNotCompletedObjective - All Objectives are completed!")
    return NONE
endFunction

QuestObjective function GetObjective(int id)
    int index = Objectives.FindStruct("ID", id)

    if(index < 0)
        return NONE
    else
        return Objectives[index]
    endif
endFunction

ObjectiveTarget function GetFirstTarget(int id, ObjectiveTarget[] targets)
    int lowestOrder = 1000
    ObjectiveTarget currentTarget = NONE
    int i = 0
    while i < targets.Length
        ObjectiveTarget target = targets[i]
        if(target.ObjectiveID == id && target.Order < lowestOrder)
            currentTarget = target
            lowestOrder = target.Order
        endif
        i += 1
    endWhile

    return currentTarget
endFunction

ObjectiveTarget function GetLastTarget(int id, ObjectiveTarget[] targets)
    int highestOrder = -1
    ObjectiveTarget currentTarget = NONE
    int i = 0
    while i < targets.Length
        ObjectiveTarget target = targets[i]
        if(target.ObjectiveID == id && target.Order > highestOrder)
            currentTarget = target
            highestOrder = target.Order
        endif
        i += 1
    endWhile

    return currentTarget
endFunction

ObjectiveTarget function GetTargetByOrder(int id, int order, ObjectiveTarget[] targets)
    int i = 0
    while i < targets.Length
        ObjectiveTarget target = targets[i]
        if(target.ObjectiveID == id && target.Order == order)
            return target
        endif
        i += 1
    endWhile

    return NONE
endFunction

; RESOLVE FUNCTIONS

bool function CompareCell(Cell currentCell, ObjectiveTarget target)
    bool result = target.TargetCell != NONE && currentCell == target.TargetCell

;    Trace("Comparing " + currentCell + " with " + target.TargetCell)
    return result
endFunction

ObjectReference function ResolvePowerArmor(ObjectiveTarget target)
    ObjectReference objRef = NONE

    if(target.Interior == _locatorsManager.IsExteriorCell())
        return NONE
    endif

    if(_testPlaceHolder == NONE)
        _testPlaceHolder = _playerReference.PlaceAtMe(ObjectivePlaceholder, 1, true, true)
    endif
    _testPlaceHolder.SetPosition(target.X, target.Y, target.Z)
    ObjectReference[] references = _testPlaceHolder.FindAllReferencesWithKeyword(PA_Keyword, 1000)
    if(references.Length > 0)
        Trace("FindAllReferencesWithKeyword Found a target! " + references[0].GetDisplayName())
        return references[0]
    endif

    ; Worst case solution. We know we are at the right place. The actor should be here!
    if(CompareCell(_locatorsManager.CurrentCell(), target))
        objRef = Game.FindClosestReferenceOfType(target.FormID, target.X, target.Y, target.Z, 1000)
        if(objRef != NONE)
            Trace("Found the object for the main FormID " + target.FormID.GetName())
            return objRef
        endif
        if(target.SecondaryFormID != NONE)
            objRef = Game.FindClosestReferenceOfType(target.SecondaryFormID, target.X, target.Y, target.Z, 1000)
            if(objRef != NONE)
                Trace("Found the object for the secondary FormID " + target.SecondaryFormID.GetName())
                return objRef
            endif
        endif

        Trace("OK, we are at the proper cell for this POWER ARMOR")
        ObjectReference[] actors = _testPlaceholder.FindAllReferencesWithKeyword(_locatorsManager.NPCKeyword, 5000)
        Actor curActor = NONE
        int i = 0
        while(i < actors.Length)
            curActor = actors[i] as Actor
            if(curActor != NONE)
                if(curActor.GetBaseObject() == target.FormID || (target.SecondaryFormID != NONE && curActor.GetBaseObject() == target.SecondaryFormID))
                    Trace("I found it by comparing to the form ids!")
                    return curActor
                endif
                if(curActor.GetActorBase() == target.FormID || (target.SecondaryFormID != NONE && curActor.GetActorBase() == target.SecondaryFormID))
                    Trace("I found it by comparing to the form ids with the actor base!")
                    return curActor
                endif
                bool isHostile = curActor.IsHostileToActor(_playerReference)
                if(curActor.IsInPowerArmor() && isHostile)
                    Trace("We found the enemy by going through the list! " + curActor.GetDisplayName())
                    return curActor
                endif
            endif
            i += 1
        endWhile
    endif

    return NONE
endFunction

function SetupPowerArmor(QuestObjective objective, ObjectReference objRef, ObjectiveTarget target)
    float distance = 0
    
    if(objective.DetectionDistance > 0)
        distance = objective.DetectionDistance
    else
        distance = PA_DetectionRange.GetValue()
    endif

    if(target.Interior)
        distance *= 0.8
    endif
    Trace("Setting up distance of " + distance + " of object " + objRef + " for objective " + objective.ID + " at pack " + PackName)
    RegisterForDistanceLessThanEvent(_playerReference, objRef, distance)
endFunction

ObjectReference function ResolvePlaceholder(QuestObjective objective, ObjectiveTarget target)
    ObjectReference placeholder = _playerReference.PlaceAtMe(ObjectivePlaceholder, 1, true, true)
    if(placeholder == NONE)
        Trace("CreatePlaceholder - Could not create the Placeholder!!!")
    else
        placeholder.SetPosition(target.X, target.Y, target.Z + 0.2)
        objective.CurrentTarget = target.Order
        objective.CurrentState == StatePlaceholder
    endif
    return placeholder
endFunction

; END RESOLVES

; CALLBACKS

event ObjectReference.OnItemAdded(ObjectReference oPlayer, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Trace("OnItemAdded - Object Collected: " + akItemReference)
    if !akSourceContainer || akSourceContainer != _playerReference
        QuestObjective objective = GetQuestObjectiveByForm(akBaseItem)
        if(objective != NONE)
            if(!KeepInvFilterUntilComplete)
                RemoveInventoryEventFilter(akBaseItem)
            endif
            CompleteObjective(objective)
        else
            Trace("OnItemAdded - Could not find Objective")
        endif

        if(IsQuestCompleted())
            Trace("OnItemAdded - Quest is completed! " + akItemReference)
            UnregisterForRemoteEvent(_playerReference, "OnItemAdded")
            CompleteQuest()
            CheckRemoveInventoryFilter(objective)
        endif
    endif
endEvent

function ProcessCellLoaded(Cell curCell)
    ChangeCell(curCell)
endFunction

event OnDistanceLessThan(ObjectReference player, ObjectReference objRef, float distance)
    Trace("OnDistanceLessThan: " + objRef.GetDisplayName())
    QuestObjective objective = GetQuestObjectiveByObjRef(objRef)
    if(objective != NONE)
        Trace("Completed Objective: " + objective.ID + " at " + PackName)
        CompleteObjective(objective)

        if(!Respawnables && IsQuestCompleted())
            Trace("OnDistanceLessThan - Quest is completed! " + objRef)
            CompleteQuest()
            CheckRemoveInventoryFilter(objective)
        endif
    else
        Trace("Could not find reference for ObjRef: " + objRef.GetDisplayName())
    endif
endEvent

;/event Quest.OnStageSet(Quest q, int auiStageID, int auiItemID)
    int i = 0

    while i < ObjectivesRequirements.Length
        ObjectiveQuestRequirement req = ObjectivesRequirements[i]
        if(req.ReqQuest == q)
            if(CanDisplayObjectiveById(req.ObjectiveID))
                SetObjectiveDisplayed(req.ObjectiveID, true)
            else
                SetObjectiveDisplayed(req.ObjectiveID, false)
            endif
        endif
        i += 1
    endWhile

    CleanRequirements()
endEvent/;

; END CALLBACKS

function ChangeCell(Cell newCell)
    if(newCell == NONE)
        Trace("Current Cell is Null!")
    endif

    ResolveQuestObjectivesByCell(newCell)
endFunction

function VerifyInstituteCell(Cell newCell)
    if(InstituteObjectiveID >= 0 && newCell == InstituteCell)
        SetObjectiveCompleted(InstituteObjectiveID)
    endif
endFunction

function ResolveObjectiveTargets(QuestObjective objective)
    ObjectiveTarget[] targets = GetNonResolvedTargets(objective.id)
    ObjectiveTarget target = NONE

    int unresolved = 0

    ObjectiveTarget firstTarget = GetFirstTarget(objective.ID, targets)

    if(firstTarget != NONE && firstTarget.OnlyInProperCell && !CompareCell(_locatorsManager.CurrentCell(), firstTarget))
        unresolved += 1
    else
        int i = targets.Length - 1
        while(i > -1)
            target = targets[i]
            if(ResolveObjective(objective, target))
                i = -5
            else
                unresolved += 1
            endif
            i -= 1

        endWhile
            
        target = GetFirstTarget(objective.ID, ObjectivesTargets)

        if(!target.PowerArmor && objective.DetectionDistance == 0)
            AddInventoryEventFilter(target.FormID)
        endif
    endif

    if(unresolved > 0)
        Trace(unresolved + " objectives were not resolved on " + PackName)
    endif
endFunction

function ResolveObjectiveTargetsOnCell(QuestObjective objective, Cell newCell, ObjectiveTarget[] targets)
    if(targets == NONE)
        targets = GetNonResolvedTargetsOnCell(objective.id, newCell)
    endif

    int i = 0
    while(i < targets.Length)
        if(ResolveObjective(objective, targets[i]))
            return
        endif
        i += 1
    endWhile
endFunction

function ResolveQuestObjectivesByCell(Cell newCell)
    QuestObjective objective
    ObjectiveTarget target

    int i = 0
    while i < Objectives.Length
        objective = Objectives[i]
        if(!IsObjectiveCompleted(objective.ID) && !ObjectiveGotDefinitiveTarget(objective))
            ObjectiveTarget[] targets = GetNonResolvedTargetsOnCell(objective.ID, newCell)
            Trace("Found " + targets.Length + " targets for objective " + objective.ID + " at " + PackName)

            if(targets.Length > 0)
                Trace("Trying to resolve objective for " + objective.ID + " at " + PackName)
                ResolveObjectiveTargetsOnCell(objective, newCell, targets)
            endif
        endif
        i += 1
    endWhile
endFunction

bool function ResolveObjective(QuestObjective objective, ObjectiveTarget target)
    if(target != NONE && target.FormID != NONE)
        ObjectReference objRef
        bool placeholder = false
        if(target.PowerArmor)
            objRef = ResolvePowerArmor(target)
        else
            objRef = ResolveItem(objective, target)
        endif

        if(objRef == NONE)
            objRef = ResolvePlaceholder(objective, target)
            placeholder = true
        endif

        if(objRef == NONE)
            Trace("********************************* NO OBJECTIVE COULD BE CREATED FOR OBJECTIVE " + objective.ID + " ON " + PackName + " *********************************")
        else
            if(placeholder)
                ;Trace("Created Placeholder Objective " + objective.ID + " on " + PackName + " with order " + target.Order)
            else
                Trace("Found Objective " + objective.ID + " on " + PackName + " with order " + target.Order)
            endif
            ApplyReference(objective, target, objRef, placeholder)
            ResolveTargetsWithOrderHigher(objective.ID, target.Order)

            ;if(CanDisplayObjective(objective))
                SetObjectiveDisplayed(objective.ID)
                Trace("Setting Objective Displayed " + objective.ID)
            ;endif
            return true
        endif
    endif
    Trace("Could not resolve objective " + objective.ID + " on " + PackName)
    return false
endFunction

function ApplyReference(QuestObjective objective, ObjectiveTarget target, ObjectReference objRef, bool placeholder)
    if(placeholder)
        objective.CurrentState = StatePlaceholder
    else
        objective.CurrentState = StateTarget
    endif
    if(target.PowerArmor || (objective.DetectionDistance > 0 && target.Order == 0))
        SetupPowerArmor(objective, objRef, target)
    endif
    ReferenceAlias aliasRef = GetAlias(objective.ID) as ReferenceAlias
    aliasRef.ForceRefTo(objRef)
    Trace("Forced Reference to " + objRef + " on " + objective.ID)

    objective.CurrentTarget = target.Order
    target.Resolved = !placeholder
endFunction

ObjectReference function ResolveItem(QuestObjective objective, ObjectiveTarget target)
    ObjectReference originalRef = NONE

    if(target.FormID == NONE)
        Trace("******************************************** ERROR FORM WITHOUT VALUE FOUND ********************************************")
        return NONE
    endif

    ;Trace("Resolving target with order: " + target.Order)
    if(target.DirectRef)
        originalRef = target.FormID as ObjectReference
        objective.CurrentState = StateTarget
        objective.CurrentTarget = 0
        target.Resolved = true
    else
        originalRef = GetReferenceAt(target.FormID, target.X, target.Y, target.Z, 50)
        if(originalRef == NONE)
            originalRef = GetReferenceAt(target.FormID, target.X, target.Y, target.Z, 300)
        endif
        if(originalRef == NONE)
            originalRef = GetReferenceAt(target.FormID, target.X, target.Y, target.Z, 5000)
        endif
    endif

    if(originalRef == NONE)
        Trace("Could not find the original ref with radius 5000")
    else
        Trace("Found original reference")
        objective.CurrentState = StateTarget
        objective.CurrentTarget = target.Order
    endif
    return originalRef
endFunction

ObjectReference function GetReferenceAt(Form id, float x, float y, float z, float radius)
    return Game.FindClosestReferenceOfType(id, x, y, z, radius)
endFunction

function ResolveTargetsWithOrderHigher(int id, int order)
    ObjectiveTarget[] targets = GetNonResolvedTargets(id)

    int i = 0    
    while i < targets.Length
        if(targets[i].Order > order)
            targets[i].Resolved = true
        endif
        i += 1
    endWhile
endFunction

QuestObjective[] function GetQuestObjectivesByCell(Cell newCell)
    QuestObjective[] objs = new QuestObjective[0]
    QuestObjective objective
    ObjectiveTarget target

    string cellName = newCell.GetName()

    int i = 0
    while i < Objectives.Length
        objective = Objectives[i]
        if(!IsObjectiveCompleted(objective.ID) && !ObjectiveGotDefinitiveTarget(objective))
            ObjectiveTarget[] targets = GetNonResolvedTargetsOnCell(objective.ID, newCell)

            if(targets.Length > 0)
                objs.Add(objective)
            endif
        endif
        i += 1
    endWhile
    return objs
endFunction

ObjectiveTarget[] function GetNonResolvedTargets(int id)
    ObjectiveTarget[] targets = new ObjectiveTarget[0]

    int i = 0
    while i < ObjectivesTargets.Length
        ObjectiveTarget target = ObjectivesTargets[i]
        if(!target.Resolved && target.ObjectiveID == id)
            targets.Add(target)
        endif
        i += 1
    endWhile

    return targets
endFunction

ObjectiveTarget[] function GetNonResolvedTargetsOnCell(int id, Cell newCell)
    ObjectiveTarget[] targets = new ObjectiveTarget[0]
    QuestObjective objective = GetObjective(id)

    int i = 0
    while i < ObjectivesTargets.Length
        ObjectiveTarget target = ObjectivesTargets[i]
        if(!target.Resolved && target.ObjectiveID == id && CompareCell(newCell, target))
;            Trace("Target " + target.Order + " from objective " + id + " has cell name " + target.TargetCell + " == " + newCell)
            if(objective.CurrentTarget < 0 || (objective.CurrentTarget > -1 && target.Order < objective.CurrentTarget))
                targets.Add(target)
            endif
        endif
        i += 1
    endWhile

    return targets
endFunction

ObjectiveTarget function GetLastNonResolvedTargetForCell(int id, Cell newCell)
    ObjectiveTarget[] targets = GetNonResolvedTargets(id)

    int i = 0
    while i < targets.Length && targets.Length != 0
        ObjectiveTarget target = targets[i]
        if(!CompareCell(newCell, target))
            targets.Remove(i)
        else
            i += 1
        endif
    endWhile

    if(targets.Length > 1)
        int highestOrder = -1
        while i < targets.Length
            ObjectiveTarget target = targets[i]
            if(target.Order > highestOrder)
                highestOrder = target.Order
            endif
            i += 1
        endWhile

        while i < targets.Length
            ObjectiveTarget target = targets[i]
            if(target.Order == highestOrder)
                i += 1
            else
                targets.Remove(i)
            endif
        endWhile
    else
         if(targets.Length == 0)
            return NONE
         endif
    endif

    return targets[0]
endFunction

bool function Trace(string asTextToPrint, int aiSeverity = 0) debugOnly
	string logName = "BARD_ObjectsLocator"
	Debug.OpenUserLog(logName)
	return Debug.TraceUser(logName, "LocatorsPackData: " + asTextToPrint, aiSeverity)
endFunction