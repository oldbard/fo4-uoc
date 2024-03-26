Scriptname BARD:OC:BARD_InitialQuest extends Quest

int _commonWealthFormID = 0x0000003C Const

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

event OnQuestInit()
    _playerReference = Game.GetPlayer() as Actor
    ;_locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
endEvent

function StartQuest(bool exterior)
	Trace("Starting Quest")
    RegisterForRemoteEvent(_playerReference, "OnItemAdded")
    AddInventoryEventFilter(HolotapeReference)

    SetActive()

	Trace("Current WorldSpace: " + NewManager.CurrentWorldSpace() + ", expecting: " + _commonWealthFormID)

    if(NewManager.CurrentWorldSpace() == _commonWealthFormID)
        if(exterior)
    	    Trace("We are at the CommonWealth at an exterior cell")
            StartExterior()
        else
    	    Trace("We are at the CommonWealth at an interior cell")
            StartInterior()
        endif
    else
	    Trace("Oh no! Where are we?")
        StartWrongWorldSpace()
    endif
endFunction

function StartExterior()
	Trace("Starting Exterior")

    if(IsObjectiveDisplayed(0))
        SetObjectiveCompleted(0)
    endif
    if(IsObjectiveDisplayed(1))
        SetObjectiveCompleted(1)
    endif

	Trace("Placing Terminal!")
    _terminal = _playerReference.PlaceAtMe(TerminalObj, 1, true)
    _terminal.WaitFor3DLoad()
    _terminal.SetPosition(_playerReference.GetPositionX(), _playerReference.GetPositionY(), _playerReference.GetPositionZ() - 50)
	Trace("Placed Terminal!")

    FinishStart()
endFunction

function FinishStart()
    _terminal.SetAngle(0, 0, TerminalRotationZ)
    _terminal.SetPosition(TerminalX, TerminalY, TerminalZ)
    
	ReferenceAlias terminalAlias = GetAlias(2) as ReferenceAlias
	terminalAlias.ForceRefTo(_terminal)
    
	Trace("Placing Drone!")
	_drone = _playerReference.PlaceAtMe(EyeBotObj) as Actor
    _drone.WaitFor3DLoad()
	_drone.SetPosition(DroneX, DroneY, DroneZ)
    
	ReferenceAlias droneAlias = GetAlias(1) as ReferenceAlias
    droneAlias.ForceRefTo(_drone as ObjectReference)

	_drone.Kill()
	Trace("Placed Drone!")

    SetStage(20)
	SetObjectiveDisplayed(2)
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
