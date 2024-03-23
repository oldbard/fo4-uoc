Scriptname BARD:OC:BARD_UOC_Manager extends Quest

BARD:OC:BARD_UOC_PackData[] Property Packages Auto

Quest Property ProximityDetector Auto
Quest Property InitialQuest Auto

GlobalVariable Property Uninstalled Auto
GlobalVariable Property TimescaleGlobal Auto
GlobalVariable Property IsExteriorGlobal Auto

MiscObject Property CellChangedDetector Auto

Actor Property PlayerReference Auto

Message Property UninstalledMessage Auto

BARD:OC:BARD_UOC_PackData[] _queuedPackages
;Quest[] _cellChangedListeners

string _currentWorldSpace = ""
bool _exteriorCell = false
bool _pendingInitialQuest = false
bool _pendingLoadPackages = false

InputEnableLayer _tempLayer = NONE
float _curTimeScale
bool _fastTravelEnabled

;BARD:OC:BARD_SectorModeController _sectorController
BARD:OC:BARD_InitialQuest _initialQuest

event OnQuestInit()
	_initialQuest = InitialQuest as BARD:OC:BARD_InitialQuest
    _queuedPackages = new BARD:OC:BARD_UOC_PackData[0]
    Packages = new BARD:OC:BARD_UOC_PackData[0]

	WorldSpace ws = PlayerReference.GetWorldSpace()

	if(ws != NONE)
		_currentWorldSpace = ws.GetName()
	endif

	Utility.Wait(10)
	UpdateIsExteriorCell()

	;_initialQuest.StartQuest(IsExteriorCell())
	;if(!IsExteriorCell())
	;	_pendingInitialQuest = true
    ;endif
    ProcessPendingPackages()

	InitCellLoadDetection()
endEvent

; Utils

bool function IsExteriorCell()
	return _exteriorCell
endFunction

string function CurrentWorldSpace()
    return _currentWorldSpace
endFunction

function UpdateIsExteriorCell()
	Cell curCell = PlayerReference.GetParentCell()

	if(curCell == NONE)
        _exteriorCell = true
    else
        _exteriorCell = !curCell.IsInterior()
	endif
	IsExteriorGlobal.SetValue(_exteriorCell as int)
endFunction

; End Utils

function AddQueuedPackage(BARD:OC:BARD_UOC_PackData pack)
    _queuedPackages.Add(pack)
    if(!_pendingLoadPackages && GetStage() >= 20)
        StartTimer(10, 7777777)
        _pendingLoadPackages = true
    endif
endFunction

function InitCellLoadDetection()
	ObjectReference placeholder = PlayerReference.PlaceAtMe(CellChangedDetector, 1, true, true)
	RegisterForRemoteEvent((PlayerReference as ObjectReference), "OnCellLoad")
endFunction

; Callbacks

event ObjectReference.OnCellLoad(ObjectReference objRef)
    UpdateIsExteriorCell()

	bool changedWorldSpace = false
	WorldSpace space = PlayerReference.GetWorldSpace()
	if(space != NONE)
		string currentWorldSpace = space.GetName()
		if(currentWorldSpace != _currentWorldSpace)
			_currentWorldSpace = currentWorldSpace
		endif
	endif

	if(IsExteriorCell())
		if(_pendingInitialQuest)
			if(_currentWorldSpace == "Commonwealth")
				_pendingInitialQuest = false
				_initialQuest.StartExterior()
			endif
		else
			int notProcessed = _queuedPackages.Length
			if(notProcessed > 0)
				Trace("Changed World Space. Packages not processed: " + notProcessed)
				if(notProcessed > 0 && GetStage() >= 20)
					ProcessPendingPackages()
				endif
			endif
		endif
	else
		int i = 0
		while i < Packages.Length
			BARD:OC:BARD_UOC_PackData pack = Packages[i]
			pack.RefreshReference(NONE)
			i += 1
		endWhile
	endif
	
	Cell curCell = PlayerReference.GetParentCell()

	Trace("OnCellLoad " + curCell + " - Exterior: " + IsExteriorCell() + " at " + _currentWorldSpace)
;/
	if(_cellChangedListeners != NONE && _cellChangedListeners.Length > 0)
		int i = 0
		while i < _cellChangedListeners.Length
			BARD:OC:BARD_ModUpdater updater = _cellChangedListeners[i] as BARD:OC:BARD_ModUpdater

			if(updater != NONE)
				updater.ProcessCellLoaded(curCell, IsExteriorCell())
			endif
			i += 1
		endWhile
	endif/;
endEvent

event OnTimer(int id)
    if(id == 7777777)
        ProcessPendingPackages()
    endif
endEvent

; END Callbacks

function ProcessPendingPackages()
    BARD:OC:BARD_UOC_PackData pack

    int i = 0
    while i < _queuedPackages.Length
        pack = _queuedPackages[i]
        Trace("Trying to Load " + pack.PackName)
        if(true);pack.CanBeInstalled(_currentWorldSpace))
            pack.LoadPackage()
            _queuedPackages.Remove(i)
			Packages.Add(pack)
			Utility.Wait(1)
        else
            Trace(pack.PackName + " could not be installed yet")
            i += 1
        endif
	endWhile
	
	SetStage(20)
endFunction

bool function Trace(string asTextToPrint, int aiSeverity = 0) debugOnly
	string logName = "BARD_ObjectsLocator"
	Debug.OpenUserLog(logName)
	return Debug.TraceUser(logName, "Manager: " + asTextToPrint, aiSeverity)
endFunction