Scriptname BARD:OC:BARD_LocatorsManager extends Quest

int _xOffset = 6 const
int _yOffset = 6 const

Quest[] Property Packages Auto Const
Quest[] _additionalPackages
Quest[] _nwPackages

MiscObject Property PlaceholderObject Auto Const

Quest Property CloserObjectives Auto Const

Quest Property InitialQuest Auto Const

Quest Property ModUpdater Auto

GlobalVariable Property ClearedCellRespawnMultiplier Auto Const
GlobalVariable Property Uninstalled Auto Const
GlobalVariable Property TimescaleGlobal Auto

Message Property UninstalledMessage Auto Const

Keyword Property NPCKeyword Auto Const
Race Property PowerArmorRace Auto Const

Form Property BadGoodneighbor Auto
Cell Property GoodGoodneighbor Auto

Form Property BadDiamondCity Auto
Cell Property GoodDiamondCity Auto

Quest[] _cellChangedListeners

Actor _playerReference

Cell _latestCell
bool _exteriorCell = false

bool _pendingLoadPackages = false

string _lastWorldSpace = ""

int _totalObjectives

InputEnableLayer _tempLayer = NONE
float _curTimeScale
bool _fastTravelEnabled

BARD:OC:BARD_SectorModeController _sectorController
BARD:OC:BARD_InitialQuest _initialQuest

Quest[] function GetAdditionalQuests()
	if(_additionalPackages == NONE)
		_additionalPackages = new Quest[0]
	endif

	return _additionalPackages
endFunction

Quest[] function GetNWQuests()
	if(_nwPackages == NONE)
		_nwPackages = new Quest[0]
	endif

	return _nwPackages
endFunction

string function GetWorldSpaceName()
	return _lastWorldSpace
endFunction

int function TotalNotProcessedQuests()
	int total = 0
	
	int i = 0
	while i < Packages.Length
		if(!(Packages[i] as BARD:OC:BARD_LocatorsPackData).Processed)
			total += 1
		endif
		i += 1
	endWhile

	i = 0
	Quest[] additionalQuests = GetAdditionalQuests()
	while i < additionalQuests.Length
		if(!(additionalQuests[i] as BARD:OC:BARD_LocatorsPackData).Processed)
			total += 1
		endif
		i += 1
	endWhile

	i = 0
	Quest[] nwQuests = GetNWQuests()
	while i < nwQuests.Length
		if(!(nwQuests[i] as BARD:OC:BARD_LocatorsPackData).Processed)
			total += 1
		endif
		i += 1
	endWhile

	return total
endFunction

event OnQuestInit()
	_playerReference = Game.GetPlayer() as Actor
	_sectorController = CloserObjectives as BARD:OC:BARD_SectorModeController
	_initialQuest = InitialQuest as BARD:OC:BARD_InitialQuest
	_additionalPackages = new Quest[0]
	_nwPackages = new Quest[0]

	WorldSpace ws = _playerReference.GetWorldSpace()

	if(ws != NONE)
		_lastWorldSpace = ws.GetName()
	endif

	Utility.Wait(5)
	UpdateIsExteriorCell()

	_initialQuest.StartQuest(IsExteriorCell())
	if(!IsExteriorCell())
		_pendingLoadPackages = true
	endif

	InitCellLoadDetection()
endEvent

function PrepareToUninstall()
	Uninstalled.SetValue(1)
	DisableAllPackages(true)
	_sectorController.Disable(true)
	_initialQuest.Disable(true)
	UninstalledMessage.Show()

	Packages.Clear()
	if(_additionalPackages != NONE)
		_additionalPackages.Clear()
		_additionalPackages = NONE
	endif
	if(_nwPackages != NONE)
		_nwPackages.Clear()
		_nwPackages = NONE
	endif
	
	BARD:OC:BARD_ModUpdater updater = ModUpdater as BARD:OC:BARD_ModUpdater
	updater.Disable(true)
	ModUpdater = NONE
	_tempLayer = NONE

	TimescaleGlobal = NONE
	_playerReference = NONE
	_latestCell = NONE
	_sectorController = NONE
	_initialQuest = NONE

	Stop()
endFunction

function InitCellLoadDetection()
	ObjectReference placeholder = _playerReference.PlaceAtMe(PlaceholderObject, 1, true, true)
	RegisterForRemoteEvent((_playerReference as ObjectReference), "OnCellLoad")
endFunction

function InitPackageLoading()
	LoadPackages()
endFunction

bool function IsExteriorCell()
	return _exteriorCell
endFunction

function UpdateIsExteriorCell()
	Cell curCell = _playerReference.GetParentCell()

	if(curCell == NONE)
        _exteriorCell = true
    else
        _exteriorCell = !curCell.IsInterior()
    endif
endFunction

function LoadPackages(bool showNotification = true)
	int packagesNotProcessed = 0

	DoFadeout()

	bool oneQuarterDone = false
	bool twoQuartersDone = false
	bool threeQuartersDone = false
	float oneQuarter = (Packages.Length) * 0.25
	float twoQuarters = (Packages.Length) * 0.5
	float threeQuarters = (Packages.Length) * 0.75
	Trace("Initializing Bard's Ultimate Objects Collector... Processing: " + (Packages.Length + _additionalPackages.Length + _nwPackages.Length) + " packages.")
	if(showNotification)
		Debug.Notification("Initializing Bard's Ultimate Objects Collector...")
	endif
	int i = Packages.Length - 1
	while i > -1
		if(!oneQuarterDone && i > oneQuarter)
			oneQuarterDone = true
			if(showNotification)
				Debug.Notification("Loading Packages 25%")
			endif
		endif
		if(oneQuarterDone && !twoQuartersDone && i > twoQuarters)
			twoQuartersDone = true
			if(showNotification)
				Debug.Notification("Loading Packages 50%")
			endif
		endif
		if(oneQuarterDone && twoQuartersDone && !threeQuartersDone && i > threeQuarters)
			threeQuartersDone = true
			if(showNotification)
				Debug.Notification("Loading Packages 75%")
			endif
		endif

		BARD:OC:BARD_LocatorsPackData packData = Packages[i] as BARD:OC:BARD_LocatorsPackData
		if(!ProcessPackage(packData))
			packagesNotProcessed += 1
		endif

        i -= 1
	endWhile

	BARD:OC:BARD_ModUpdater updater = ModUpdater as BARD:OC:BARD_ModUpdater
	updater.SendData()
	
	EnableAllPackages()

	Trace("Bard's Ultimate Objects Collector Initialization Finished - " + _totalObjectives + " Objectives!")
	if(showNotification)
		Debug.Notification("Loading Packages 100%. Bard's Ultimate Objects Collector Initialization Finished!")
	endif

	if(packagesNotProcessed > 0)
		Trace(packagesNotProcessed + " Packages were not processed.")
	endif

	DoFadeIn()

	SetStage(20)
endFunction

function DoFadeout()
    _curTimeScale = TimescaleGlobal.GetValue()

	TimescaleGlobal.SetValue(1)
	Game.FadeOutGame(true, true, 1, 2, true)

	_tempLayer = InputEnableLayer.Create()
	_fastTravelEnabled = Game.IsFastTravelEnabled()
	_tempLayer.EnableFastTravel(false)
	_tempLayer.DisablePlayerControls()
endFunction

function DoFadeIn()
	Game.FadeOutGame(false, true, 1, 1)
	TimescaleGlobal.SetValue(_curTimeScale)

	_tempLayer.EnableFastTravel(_fastTravelEnabled)
	_tempLayer.EnablePlayerControls()
endFunction

bool function HasSameWorldSpace(string worldSpaceName)
	return _lastWorldSpace == worldSpaceName || (_lastWorldSpace == "Diamond City" && worldSpaceName == "Commonwealth") || (_lastWorldSpace == "Goodneighbor" && worldSpaceName == "Commonwealth") || (_lastWorldSpace == "NukaWorldMarket" && worldSpaceName == "Nuka-World")
endFunction

bool function ProcessPackage(BARD:OC:BARD_LocatorsPackData packData)
	if(!packData.Processed && HasSameWorldSpace(packData.WorldSpaceName))
		LoadPackage(packData)
		return true
	endif

	return false
endFunction

function LoadPackage(BARD:OC:BARD_LocatorsPackData packData)
	packData.LoadPackData()

	_totalObjectives += packData.Objectives.Length
    Trace("Loaded " + packData.Objectives.Length + " Objectives")
endFunction

function EnableAllPackages()
	Quest[] nwQuests = GetNWQuests()
	int i = nwQuests.Length - 1
	while i > -1
		ToggleNWPackage(i, true)
		i -= 1
	endWhile

	Quest[] additionalQuests = GetAdditionalQuests()
	i = additionalQuests.Length - 1
	while i > -1
		ToggleAdditionalPackage(i, true)
		i -= 1
	endWhile

	i = Packages.Length - 1
	while i > -1
		TogglePackage(i, true)
		i -= 1
	endWhile
	SetStage(30)
endFunction

function DisableAllPackages(bool stop)
	int i = 0
	Quest[] nwQuests = GetNWQuests()
	while i < nwQuests.Length
		ToggleNWPackage(i, false)
		if(stop)
			nwQuests[i].Stop()
		endif
		i += 1
	endWhile
	
	i = 0
	Quest[] additionalQuests = GetAdditionalQuests()
	while i < additionalQuests.Length
		ToggleAdditionalPackage(i, false)
		if(stop)
			additionalQuests[i].Stop()
		endif
		i += 1
	endWhile

	i = 0
	while i < Packages.Length
		TogglePackage(i, false)
		if(stop)
			Packages[i].Stop()
		endif
		i += 1
	endWhile
	SetStage(30)
endFunction

function TogglePackage(int id, bool enable)
	BARD:OC:BARD_LocatorsPackData packData = Packages[id] as BARD:OC:BARD_LocatorsPackData
	TogglePackData(packData, enable)
endFunction

function ToggleAdditionalPackage(int id, bool enable)
	Quest[] additionalQuests = GetAdditionalQuests()

	BARD:OC:BARD_LocatorsPackData packData = additionalQuests[id] as BARD:OC:BARD_LocatorsPackData
	TogglePackData(packData, enable)
endFunction

function ToggleNWPackage(int id, bool enable)
	Quest[] nwQuests = GetNWQuests()

	BARD:OC:BARD_LocatorsPackData packData = nwQuests[id] as BARD:OC:BARD_LocatorsPackData
	TogglePackData(packData, enable)
endFunction

function TogglePackData(BARD:OC:BARD_LocatorsPackData packData, bool enable)
	if(enable)
		if(!packData.Enabled)
			packData.EnablePack()
		endif
	else
		if(packData.Enabled)
			packData.DisablePack()
		endif
	endif
endFunction

function AddPack(BARD_LocatorsPackData packData)
	Quest[] additionalQuests
	if(packData.WorldSpaceName == "Commonwealth")
		additionalQuests = GetAdditionalQuests()
	else
		additionalQuests = GetNWQuests()
	endif
	additionalQuests.Add(packData)
	ProcessPendingPackage(packData)

	if(_sectorController.Loaded)
		_sectorController.LoadPackData(packData)
	endif
	Trace("Added Pack " + packData.PackName + ". Total of " + (additionalQuests.Length + Packages.Length))
endFunction

function ShowPack(int id, bool additional = false)
	BARD:OC:BARD_LocatorsPackData packData = NONE
	if(additional)
		Quest[] additionalQuests = GetAdditionalQuests()
		packData = additionalQuests[id] as BARD:OC:BARD_LocatorsPackData
	else
		packData = Packages[id] as BARD:OC:BARD_LocatorsPackData
	endif

	if(!packData.Visible)
		packData.ShowPack()
	endif
endFunction

function HidePack(int id, bool additional = false)
	BARD:OC:BARD_LocatorsPackData packData = NONE
	if(additional)
		Quest[] additionalQuests = GetAdditionalQuests()
		packData = additionalQuests[id] as BARD:OC:BARD_LocatorsPackData
	else
		packData = Packages[id] as BARD:OC:BARD_LocatorsPackData
	endif

	if(packData.Visible)
		packData.HidePack()
	endif
endFunction

function ShowDLCPack(int id, string worldName)
	BARD:OC:BARD_LocatorsPackData packData = NONE
	Quest[] additionalQuests
	if(worldName == "Commonwealth")
		additionalQuests = GetAdditionalQuests()
	else
		additionalQuests = GetNWQuests()
	endif
	packData = additionalQuests[id] as BARD:OC:BARD_LocatorsPackData

	if(!packData.Visible)
		packData.ShowPack()
	endif
endFunction

function HideDLCPack(int id, string worldName)
	BARD:OC:BARD_LocatorsPackData packData = NONE
	Quest[] additionalQuests
	if(worldName == "Commonwealth")
		additionalQuests = GetAdditionalQuests()
	else
		additionalQuests = GetNWQuests()
	endif
	packData = additionalQuests[id] as BARD:OC:BARD_LocatorsPackData

	if(packData.Visible)
		packData.HidePack()
	endif
endFunction

function ProcessPendingPackages()
	int totalProcessed = 0
	
	totalProcessed += ProcessPendingPackageData(Packages)
	totalProcessed += ProcessPendingPackageData(GetNWQuests())
	totalProcessed += ProcessPendingPackageData(GetAdditionalQuests())

	if(totalProcessed > 0)
		Trace("A Total of " + totalProcessed + " pending packages were processed.")
	endif
endFunction

int function ProcessPendingPackageData(Quest[] quests)
	int totalProcessed = 0

	int i = 0
	while i < quests.Length
		BARD:OC:BARD_LocatorsPackData packData = quests[i] as BARD:OC:BARD_LocatorsPackData
		if(!packData.Processed && HasSameWorldSpace(packData.WorldSpaceName))
			if(ProcessPendingPackage(packData))
				totalProcessed += 1
			endif
		endif
		i += 1
	endWhile

	return totalProcessed
endFunction

bool function ProcessPendingPackage(BARD:OC:BARD_LocatorsPackData packData)
	if(packData.Processed == false && ProcessPackage(packData))
		packData.EnablePack()
		return true
	endif
	return false
endFunction

function EnableDistanceDetection()
	Trace("Enabling Distance Detection")

	if(!_sectorController.Loaded)
		Quest[] quests = new Quest[0]

		int i = 0
		while i < Packages.Length
			quests.Add(Packages[i])
			i += 1
		endWhile

		Quest[] nwQuests = GetNWQuests()
		i = 0
		while i < nwQuests.Length
			quests.Add(nwQuests[i])
			i += 1
		endWhile

		Quest[] additionalQuests = GetAdditionalQuests()
		i = 0
		while i < additionalQuests.Length
			quests.Add(additionalQuests[i])
			i += 1
		endWhile

		_sectorController.Initialize(quests)
	endIf
	_sectorController.Enable()
endFunction

function DisableDistanceDetection()
	Trace("Disabling Distance Detection")
	_sectorController.Disable(false)
endFunction

function MoveToNextObjective(int id, int jumpTo)
	BARD:OC:BARD_LocatorsPackData packData = Packages[id] as BARD:OC:BARD_LocatorsPackData
	packData.MoveToNextObjective(jumpTo)
endFunction

function MoveToNextAdditionalObjective(int id, int jumpTo)
	Quest[] additionalQuests = GetAdditionalQuests()

	BARD:OC:BARD_LocatorsPackData packData = additionalQuests[id] as BARD:OC:BARD_LocatorsPackData
	packData.MoveToNextObjective(jumpTo)
endFunction

function MoveToNextNWObjective(int id, int jumpTo)
	Quest[] additionalQuests = GetNWQuests()

	BARD:OC:BARD_LocatorsPackData packData = additionalQuests[id] as BARD:OC:BARD_LocatorsPackData
	packData.MoveToNextObjective(jumpTo)
endFunction

function CompleteNextObjective(int id, int jumpTo)
	BARD:OC:BARD_LocatorsPackData packData = Packages[id] as BARD:OC:BARD_LocatorsPackData
	packData.CompleteNextObjective(jumpTo)
endFunction

function CompleteNextAdditionalObjective(int id, int jumpTo)
	Quest[] additionalQuests = GetAdditionalQuests()

	BARD:OC:BARD_LocatorsPackData packData = additionalQuests[id] as BARD:OC:BARD_LocatorsPackData
	packData.CompleteNextObjective(jumpTo)
endFunction

function CompleteNextNWObjective(int id, int jumpTo)
	Quest[] additionalQuests = GetNWQuests()

	BARD:OC:BARD_LocatorsPackData packData = additionalQuests[id] as BARD:OC:BARD_LocatorsPackData
	packData.CompleteNextObjective(jumpTo)
endFunction

function ObjectiveCompleted(BARD:OC:BARD_LocatorsPackData packData, BARD:OC:BARD_LocatorsPackData:QuestObjective objective)
	_sectorController.ObjectiveCompleted(packData, objective.ID)
endFunction

function CompletedObjective(BARD:OC:BARD_LocatorsPackData packData, int id)
	_sectorController.ObjectiveCompleted(packData, id)
endFunction

Cell function CurrentCell()
	return _latestCell
endFunction

event ObjectReference.OnCellLoad(ObjectReference objRef)
	OnCellChanged()
endEvent

function OnCellChanged()
	return
	UpdateIsExteriorCell()

	bool changedWorldSpace = false
	WorldSpace space = _playerReference.GetWorldSpace()
	if(space != NONE)
		string currentWorldSpace = space.GetName()
		if(currentWorldSpace != _lastWorldSpace)
			_lastWorldSpace = currentWorldSpace
		endif
	endif

	if(IsExteriorCell())
		if(_pendingLoadPackages)
			if(_lastWorldSpace == "Commonwealth")
				_pendingLoadPackages = false
				_initialQuest.StartExterior()
			endif
		else
			int notProcessed = TotalNotProcessedQuests()
			if(notProcessed > 0)
				Trace("Changed World Space. Packages not processed: " + TotalNotProcessedQuests())
				if(TotalNotProcessedQuests() > 0 && GetStage() >= 20)
					ProcessPendingPackages()
				endif
			endif
		endif
	endif
	
	Cell curCell = _playerReference.GetParentCell()
	
	if(curCell == _latestCell)
		return
	endif
	
	if(curCell == BadGoodneighbor)
		Trace("Found the BadGoodneighbor Cell. Switched it to the good one")
		curCell = GoodGoodneighbor
	endif
	
	if(curCell == BadDiamondCity)
		Trace("Found the BadDiamondCity Cell. Switched it to the good one")
		curCell = GoodDiamondCity
	endif

	Trace("OnCellLoad " + curCell + " - Exterior: " + IsExteriorCell() + " at " + _lastWorldSpace)
	
	_latestCell = curCell
	
	ProcessCellLoadOnPackages(Packages, curCell)
	ProcessCellLoadOnPackages(GetNWQuests(), curCell)
	ProcessCellLoadOnPackages(GetAdditionalQuests(), curCell)

	if(_cellChangedListeners != NONE && _cellChangedListeners.Length > 0)
		int i = 0
		while i < _cellChangedListeners.Length
			BARD:OC:BARD_ModUpdater updater = _cellChangedListeners[i] as BARD:OC:BARD_ModUpdater

			if(updater != NONE)
				updater.ProcessCellLoaded(curCell, IsExteriorCell())
			endif
			i += 1
		endWhile
	endif
endFunction

function ProcessCellLoadOnPackages(Quest[] packs, Cell curCell)
	int i = 0
	while i < packs.Length
		BARD:OC:BARD_LocatorsPackData packData = packs[i] as BARD:OC:BARD_LocatorsPackData
		if(packData.Enabled == true && packData.Visible == true && !packData.IsCompleted())
			if(HasSameWorldSpace(packData.WorldSpaceName))
				packData.ProcessCellLoaded(curCell)
			endif
		endif
        i += 1
	endWhile
endFunction

; LISTENERS

function AddCellChangeListener(Quest listener)
	if(_cellChangedListeners == NONE)
		_cellChangedListeners = new Quest[0]
	endif

	_cellChangedListeners.Add(listener)
endFunction

function RemoveCellChangeListener(Quest listener)
	int i = 0
	while i < _cellChangedListeners.Length
		Quest curListener = _cellChangedListeners[i]
		if(curListener == listener)
			_cellChangedListeners.Remove(i)
		endif
		i += 1
	endWhile
endFunction

; END LISTENERS

bool function Trace(string asTextToPrint, int aiSeverity = 0) debugOnly
	string logName = "BARD_ObjectsLocator"
	Debug.OpenUserLog(logName)
	return Debug.TraceUser(logName, "LocatorsManager: " + asTextToPrint, aiSeverity)
endFunction
