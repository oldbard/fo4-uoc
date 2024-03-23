Scriptname BARD:OC:BARD_InitialQuest extends Quest

Message Property MessageOverrideStart Auto Const

Form Property TerminalObj Auto Const
ActorBase Property EyeBotObj Auto Const

Float Property TerminalX Auto Const
Float Property TerminalY Auto Const
Float Property TerminalZ Auto Const
Float Property TerminalRotationZ Auto Const
Float Property DroneX Auto Const
Float Property DroneY Auto Const
Float Property DroneZ Auto Const

Holotape Property HolotapeReference Auto Const

Quest Property Manager Auto Const
BARD:OC:BARD_UOC_Manager Property NewManager Auto

Actor _playerReference

bool _pendingHolotape = true

BARD:OC:BARD_LocatorsManager _locatorsManager

ObjectReference _terminal
Actor _drone

float Property MaxWaitingTime = 10.0 Auto Const

event OnQuestInit()
    _playerReference = Game.GetPlayer() as Actor
    ;_locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
endEvent

function StartQuest(bool exterior)
    RegisterForRemoteEvent(_playerReference, "OnItemAdded")
    AddInventoryEventFilter(HolotapeReference)

    SetActive()

    if(NewManager.CurrentWorldSpace() == "Commonwealth")
        if(exterior)
            StartExterior()
        else
            StartInterior()
        endif
    else
        StartWrongWorldSpace()
    endif
endFunction

function StartExterior()
    if(IsObjectiveDisplayed(0))
        SetObjectiveCompleted(0)
    endif
    if(IsObjectiveDisplayed(1))
        SetObjectiveCompleted(1)
    endif

    _terminal = _playerReference.PlaceAtMe(TerminalObj, 1)
    _terminal.SetPosition(_playerReference.GetPositionX(), _playerReference.GetPositionY(), _playerReference.GetPositionZ() - 50)
    
    bool stopWaiting = false
    float waitedTime = 0
    
    while(!_terminal.Is3dLoaded() && !stopWaiting)
        waitedTime += 0.1
        if(waitedTime > MaxWaitingTime)
            stopWaiting = true
        else
            Utility.Wait(0.1)
            Trace("Waited a bit for terminal model to load")
        endif
    endWhile

    if(stopWaiting)
        FinishWithoutQuest()
    else
        FinishStart()
    endif
endFunction

function FinishStart()
    _terminal.SetAngle(0, 0, TerminalRotationZ)
    _terminal.SetPosition(TerminalX, TerminalY, TerminalZ)
    
	ReferenceAlias terminalAlias = GetAlias(2) as ReferenceAlias
	terminalAlias.ForceRefTo(_terminal)
    
	_drone = _playerReference.PlaceAtMe(EyeBotObj) as Actor
	_drone.SetPosition(DroneX, DroneY, DroneZ)
    
	ReferenceAlias droneAlias = GetAlias(1) as ReferenceAlias
    droneAlias.ForceRefTo(_drone as ObjectReference)

	_drone.Kill()

    SetStage(20)
	SetObjectiveDisplayed(2)
endFunction

function FinishWithoutQuest()
    _terminal.Delete()
    SetStage(30)
    Disable(false)
    Trace("Finished Without Quest")

    MessageOverrideStart.Show()

    (Manager as BARD:OC:BARD_LocatorsManager).InitPackageLoading()
	ObjectReference holo = _playerReference.PlaceAtMe(HolotapeReference, 1, true, true)
    _playerReference.AddItem(holo)
endFunction

function StartInterior()
    SetObjectiveDisplayed(0)
    SetStage(15)
endFunction

function StartWrongWorldSpace()
    SetObjectiveDisplayed(1)
    SetStage(12)
endFunction

function Disable(bool stop)
    UnregisterForRemoteEvent(_playerReference, "OnItemAdded")
    RemoveInventoryEventFilter(HolotapeReference)
    UnregisterForAllEvents()
    if(stop)
        if(_terminal != NONE)
            _terminal.Disable()
            _terminal.Delete()
            _terminal = NONE
        endif
        if(_drone != NONE)
            _drone.Disable()
            _drone.Delete()
            _drone = NONE
        endif

        _playerReference = NONE

        Stop()
    endif
endFunction

event OnStageSet(int stageId, int itemId)
    if(stageId == 25)
        if(_pendingHolotape)
            SetObjectiveDisplayed(3)
        else
            SetStage(30)
        endif
    endif
    if(stageId == 30)
        CompleteQuest()
    endif
endEvent

event ObjectReference.OnItemAdded(ObjectReference oPlayer, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    UnregisterForRemoteEvent(_playerReference, "OnItemAdded")
    RemoveInventoryEventFilter(HolotapeReference)
    _pendingHolotape = false
    if(GetStage() == 25)
        SetObjectiveCompleted(3)
        SetStage(30)
    endif
endEvent

bool function Trace(string asTextToPrint, int aiSeverity = 0) debugOnly
	string logName = "BARD_ObjectsLocator"
	Debug.OpenUserLog(logName)
	return Debug.TraceUser(logName, "InitialQuest: " + asTextToPrint, aiSeverity)
endFunction
