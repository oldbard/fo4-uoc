Scriptname BARD:OC:BARD_SectorModeController extends Quest

int MaxArraySize = 128 const

Quest Property Manager Auto Const

GlobalVariable Property DetectionMinDistance Auto Const
GlobalVariable Property DetectionMaxDistance Auto Const
GlobalVariable Property DistanceDetectionEnabled Auto Const

struct ObjectiveData
    BARD:OC:BARD_LocatorsPackData QuestPack
    ObjectReference TargetObject
    int ObjectiveID
    float X
    float Y
endStruct

Quest[] _quests
ObjectiveData[] _allObjectives1
ObjectiveData[] _allObjectives2
ObjectiveData[] _allObjectives3
ObjectiveData[] _allObjectives4
ObjectiveData[] _allObjectives5

Actor _playerReference

float _lastPosX
float _lastPosY

bool Property Loaded = false Auto

BARD:OC:BARD_LocatorsManager _locatorsManager

event OnQuestInit()
    Trace("SectorModeController Initialized")
endEvent

function Initialize(Quest[] questsArray)
    _quests = questsArray

    _playerReference = Game.GetPlayer()
    _lastPosX = _playerReference.GetPositionX()
    _lastPosY = _playerReference.GetPositionY()

    _allObjectives1 = new ObjectiveData[0]
    _allObjectives2 = new ObjectiveData[0]
    _allObjectives3 = new ObjectiveData[0]
    _allObjectives4 = new ObjectiveData[0]
    _allObjectives5 = new ObjectiveData[0]
    
    LoadAllObjectives()

    Loaded = true

    Trace("All Data Processed")
endFunction

BARD:OC:BARD_LocatorsManager function GetManager()
    if(_locatorsManager == NONE)
        _locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
    endif
    return _locatorsManager
endFunction


function LoadAllObjectives()
    int totalObjectivesProcessed = 0

    int i = 0
    while i < _quests.Length
        BARD:OC:BARD_LocatorsPackData packData = _quests[i] as BARD:OC:BARD_LocatorsPackData
        totalObjectivesProcessed += LoadPackData(packData)
        i += 1
    endWhile
    Trace("A total of " + totalObjectivesProcessed + " objectives were processed")
endFunction

int function LoadPackData(BARD:OC:BARD_LocatorsPackData packData)
    ObjectiveData[] allObjectives
    int totalObjectivesProcessed = 0

    Trace("Processing Package " + packData.PackName)
    int j = 0

    while j < packData.Objectives.Length
        if(!packData.IsQuestCompleted() && packData.Enabled)
            BARD:OC:BARD_LocatorsPackData:QuestObjective objective = packData.Objectives[j]
            if(!packData.IsObjectiveCompleted(objective.ID))
                BARD:OC:BARD_LocatorsPackData:ObjectiveTarget target = packData.GetLastTarget(objective.ID, packData.ObjectivesTargets)
                
                ObjectiveData data = new ObjectiveData
                data.QuestPack = packData
                data.ObjectiveID = objective.ID
                if(objective.PlaceHolder != NONE)
                    data.TargetObject = objective.PlaceHolder
                else
                    data.TargetObject = objective.AliasReference.GetReference()
                endif
                data.X = target.X
                data.Y = target.Y

                allObjectives = GetAvailableArray()
                allObjectives.Add(data)

                totalObjectivesProcessed += 1

                if(!packData.IsActive())
                    packData.SetActive()
                endif
            endif
        endif
        j += 1
    endWhile

    return totalObjectivesProcessed
endFunction

ObjectReference function GetReference(ObjectiveData data)
    BARD:OC:BARD_LocatorsPackData:QuestObjective objective = data.QuestPack.GetObjective(data.ObjectiveID)

    if(objective == NONE)
        Trace("ERROR! Could not find Objective with ID: " + data.ObjectiveID)
        return NONE
    endif

    if(objective.PlaceHolder != NONE)
        return objective.PlaceHolder
    else
        return objective.AliasReference.GetReference()
    endif
    return NONE
endFunction

function Enable()
    DistanceDetectionEnabled.SetValue(1)

    ToggleObjectives(_allObjectives1)
    ToggleObjectives(_allObjectives2)
    ToggleObjectives(_allObjectives3)
    ToggleObjectives(_allObjectives4)
    ToggleObjectives(_allObjectives5)

    Trace("All Data Enabled")
endFunction

function ToggleObjectives(ObjectiveData[] allObjectives)
    ObjectiveData data
    int totalReenabled = 0

    int i = 0
    while i < allObjectives.Length
        data = allObjectives[i]

        if(data.QuestPack.Visible && !data.QuestPack.IsObjectiveCompleted(data.ObjectiveID)); && data.QuestPack.CanDisplayObjectiveById(data.ObjectiveID))
            if(GetManager().HasSameWorldSpace(data.QuestPack.WorldSpaceName))
                data.QuestPack.SetActive(true)
                if(data.TargetObject != NONE)
                    ToggleObjective(data, false)
                endif
                totalReenabled += 1
            else
                data.QuestPack.SetActive(false)
            endif
        endif

        i += 1
    endWhile

    Trace("A total of " + totalReenabled + " objectives were Re-Enabled")
endFunction

function Disable(bool stop)
    DistanceDetectionEnabled.SetValue(0)

    DisableObjectives(_allObjectives1)
    DisableObjectives(_allObjectives2)
    DisableObjectives(_allObjectives3)
    DisableObjectives(_allObjectives4)
    DisableObjectives(_allObjectives5)

    UnregisterForAllEvents()
    if(stop)
        _quests = NONE
        _allObjectives1 = NONE
        _allObjectives2 = NONE
        _allObjectives3 = NONE
        _allObjectives4 = NONE
        _allObjectives5 = NONE
        
        Stop()
    endif

    Trace("All Data Disabled")
endFunction

function DisableObjectives(ObjectiveData[] allObjectives)
    ObjectiveData data
    int totalReenabled = 0

    int i = 0
    while i < allObjectives.Length
        data = allObjectives[i]

        ObjectReference ref = GetReference(data)

        if(ref != NONE)
            UnregisterForDistanceEvents(_playerReference, data.TargetObject)
        endif
        if(!data.QuestPack.IsObjectiveCompleted(data.ObjectiveID))
            data.QuestPack.SetActive(false)
            data.QuestPack.SetObjectiveDisplayed(data.ObjectiveID)
            totalReenabled += 1
        endif

        i += 1
    endWhile

    Trace("A total of " + totalReenabled + " objectives were Re-Enabled")
endFunction

ObjectiveData[] function GetAvailableArray()
    if(IsArrayAvailable(_allObjectives1))
        return _allObjectives1
    elseif(IsArrayAvailable(_allObjectives2))
        return _allObjectives2
    elseif(IsArrayAvailable(_allObjectives3))
        return _allObjectives3
    elseif(IsArrayAvailable(_allObjectives4))
        return _allObjectives4
    elseif(IsArrayAvailable(_allObjectives5))
        return _allObjectives5
    endif
endFunction

bool function IsArrayAvailable(ObjectiveData[] dataArray)
    if(dataArray.Length < MaxArraySize)
        return true
    endif
    return false
endFunction

; EVENTS

function ObjectiveCompleted(BARD:OC:BARD_LocatorsPackData questPack, int id)
    if (TryCompleteObjective(questPack, id, _allObjectives1))
        return
    endif
    if (TryCompleteObjective(questPack, id, _allObjectives2))
        return
    endif
    if (TryCompleteObjective(questPack, id, _allObjectives3))
        return
    endif
    if (TryCompleteObjective(questPack, id, _allObjectives4))
        return
    endif
    if (TryCompleteObjective(questPack, id, _allObjectives5))
        return
    endif
endFunction

bool function TryCompleteObjective(BARD:OC:BARD_LocatorsPackData questPack, int id, ObjectiveData[] dataArray)
    int index = GetDataArrayIndexByID(questPack, id, dataArray)
    if(index > -1)
        Trace("TryCompleteObjective - Objective found and disabled")

        ObjectiveData data = dataArray[index]

        ObjectReference ref = data.TargetObject

        if(ref != NONE)
            UnregisterForDistanceEvents(_playerReference, ref)
        endif
        if(!questPack.Respawnables)
            dataArray.Remove(index)
        endif
        return true
    endif
    return false
endFunction

event OnDistanceLessThan(ObjectReference player, ObjectReference objRef, float distance)
    ToggleObjectiveByDistance(objRef, true)
endEvent

event OnDistanceGreaterThan(ObjectReference player, ObjectReference objRef, float distance)
    ToggleObjectiveByDistance(objRef, false)
endEvent

function ToggleObjectiveByDistance(ObjectReference objRef, bool enable)
    if(TryToggleObjective(_allObjectives1, objRef, enable))
        return
    endif
    if(TryToggleObjective(_allObjectives2, objRef, enable))
        return
    endif
    if(TryToggleObjective(_allObjectives3, objRef, enable))
        return
    endif
    if(TryToggleObjective(_allObjectives4, objRef, enable))
        return
    endif
    if(TryToggleObjective(_allObjectives5, objRef, enable))
        return
    endif
endFunction

bool function TryToggleObjective(ObjectiveData[] dataArray, ObjectReference objRef, bool enable)
    int index = GetDataArrayIndexByReference(objRef, dataArray)
    if(index < 0)
        return false
    endif

    ObjectiveData data = dataArray[index]
    if(data.QuestPack.IsObjectiveCompleted(data.ObjectiveID))
        if(!data.QuestPack.Respawnables)
            dataArray.Remove(index)
        endif
    else
        if(data.QuestPack.Visible); && data.QuestPack.CanDisplayObjectiveById(data.ObjectiveID))
            ToggleObjective(data, enable)
        endif
    endif
    return true
endFunction

function ToggleObjective(ObjectiveData data, bool enable)
    data.QuestPack.SetObjectiveDisplayed(data.ObjectiveID, enable)
    if(data.TargetObject == NONE)
        Trace("Objective " + data.ObjectiveID + " at " + data.QuestPack.PackName + " is missing a target!")
    endif
    if(enable)
        RegisterForDistanceGreaterThanEvent(_playerReference, data.TargetObject, DetectionMaxDistance.GetValue())
    else
        RegisterForDistanceLessThanEvent(_playerReference, data.TargetObject, DetectionMinDistance.GetValue())
    endif
endFunction

int function GetDataArrayIndexByReference(ObjectReference objRef, ObjectiveData[] dataArray)
    return dataArray.FindStruct("TargetObject", objRef)
endFunction

int function GetDataArrayIndexByID(BARD:OC:BARD_LocatorsPackData questPack, int id, ObjectiveData[] dataArray)
    ObjectiveData data

    int index = -1
    int startPos = 0
    bool keepSearching = true
    int maxLength = MaxArraySize
    if(dataArray.Length < MaxArraySize)
        maxLength = dataArray.Length
    endif
    while keepSearching && startPos < maxLength
        index = dataArray.FindStruct("QuestPack", questPack, startPos)
        if(index >= 0)
            data = dataArray[index]
            if(data.ObjectiveID == id)
                keepSearching = false
            else
                startPos = index + 1
            endif
        else
            keepSearching = false
        endif
    endWhile
    return index
endFunction

; END EVENTS

bool function Trace(string asTextToPrint, int aiSeverity = 0) debugOnly
	string logName = "BARD_ObjectsLocator"
	Debug.OpenUserLog(logName)
	return Debug.TraceUser(logName, "SectorModeController: " + asTextToPrint, aiSeverity)
endFunction
