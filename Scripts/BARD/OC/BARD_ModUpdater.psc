Scriptname BARD:OC:BARD_ModUpdater extends Quest

struct UpdatePackage
    Quest PackData
    float Version
    bool Processed
endStruct

struct UpdaterQuest
    Quest Updater
    float Version
    bool Processed
endStruct

Quest Property Manager Auto

GlobalVariable Property VersionGlobal Auto
GlobalVariable Property DistanceDetectionEnabled Auto

UpdatePackage[] _packages
UpdaterQuest[] _updaters

BARD:OC:BARD_LocatorsManager _locatorsManager

Actor _playerReference

bool _queueSendData

event OnQuestInit()
    _playerReference = Game.GetPlayer() as Actor
    _locatorsManager = Manager as BARD:OC:BARD_LocatorsManager
endEvent

function TryQueueSendData()
    if(_queueSendData == false)
        _queueSendData = true

        Utility.Wait(10)

        if(_locatorsManager.GetStage() >= 30)
            if(CanProcessData())
                ProcessData()
            else
                _locatorsManager.AddCellChangeListener(self)
            endif
        endif
    endif
endFunction

bool function CanProcessData()
    if(_locatorsManager.IsExteriorCell())
        UpdatePackage pack = GetLowestVersionPack()
        if(pack != NONE && _locatorsManager.HasSameWorldSpace((pack.PackData as BARD:OC:BARD_LocatorsPackData).WorldSpaceID))
            return true
        endif
    endif

    return false
endFunction

function ProcessData()
    bool dDEnabled = DistanceDetectionEnabled.GetValue() > 0
    _locatorsManager.DoFadeOut()
    if(dDEnabled)
        _locatorsManager.DisableDistanceDetection()
    endif
    SendData()
    if(dDEnabled)
        _locatorsManager.EnableDistanceDetection()
    endif
    _locatorsManager.DoFadeIn()
endFunction

function Disable(bool stop)
    UnregisterForAllEvents()
    if(_packages != NONE)
        _packages.Clear()
    endif

    if(stop)
        Trace("Stopped Quest")
        _playerReference = NONE
        Manager = NONE
        _packages = NONE
        VersionGlobal = NONE
        DistanceDetectionEnabled = NONE

        Stop()
    endif
endFunction

function AddUpdater(Quest updater, float version)
    if(_updaters == NONE)
        _updaters = new UpdaterQuest[0]
    endif

    UpdaterQuest upQuest = new UpdaterQuest
    upQuest.Updater = updater
    upQuest.Version = version

    _updaters.Add(upQuest)
endFunction

function AddPackData(Quest[] packages, float version)
    if(_packages == NONE)
        _packages = new UpdatePackage[0]
    endif

    int i = 0
    while i < packages.Length
        Quest packData = packages[i]

        UpdatePackage pack = new UpdatePackage
        pack.PackData = packData
        pack.Version = version

        _packages.Add(pack)
        i += 1
    endWhile

    TryQueueSendData()
endFunction

function ProcessCellLoaded(int curCell, bool exterior)
    Trace("ProcessCellLoaded")
    if(CanProcessData())
        Trace("ProcessCellLoaded - Can process data!")
        ProcessData()
    endif
endFunction

bool function SendData()
    while CanProcessData() && !SentAllPacks()
        UpdatePackage pack = GetLowestVersionPack()
        if(pack == NONE)
            Trace("No pack was found! It should not have happened")
            return false
        else
            UpdaterQuest updater = GetNonProcessedVersionUpdater(pack.Version)
            if(updater != NONE)
                updater.Processed = true
                (updater.Updater as BARD:OC:BARD_UpdaterPack).ProcessUpdate()
                
                VersionGlobal.SetValue(updater.Version)
            endif
            
            _locatorsManager.AddPack(pack.PackData as BARD:OC:BARD_LocatorsPackData)
            pack.Processed = true
        endif
    endWhile
    int index = _packages.FindStruct("Processed", false)

    if(index < 0)
        _queueSendData = false
        Disable(false)
        Trace("All packs were sent. Unregistering listener")
        _locatorsManager.RemoveCellChangeListener(self)
    else
        Trace("Some packs were not sent yet!")
        _locatorsManager.AddCellChangeListener(self)
    endif

    return true
endFunction

bool function SentAllPacks()
    int i = 0

    while i < _packages.Length
        if(_packages[i].Processed == false)
            return false
        endif
        i += 1
    endWhile
    return true
endFunction

UpdaterQuest function GetNonProcessedVersionUpdater(float version)
    int i = 0
    while i < _updaters.Length
        UpdaterQuest updater = _updaters[i]
        if(updater.Processed == false && updater.Version == version)
            return updater
        endif
        i += 1
    endWhile
    return NONE
endFunction

UpdatePackage function GetLowestVersionPack()
    UpdatePackage lowestVersionPack = NONE
    float lowestVersion = 99999

    int i = 0
    while i < _packages.Length
        UpdatePackage pack = _packages[i]
        if(pack.Processed == false && pack.Version < lowestVersion)
            BARD:OC:BARD_LocatorsPackData packData = pack.PackData as BARD:OC:BARD_LocatorsPackData
            if(_locatorsManager.HasSameWorldSpace(packData.WorldSpaceID))
                lowestVersion = pack.Version
                lowestVersionPack = pack
            endif
        endif
        i += 1
    endWhile

    return lowestVersionPack
endFunction

bool function Trace(string asTextToPrint, int aiSeverity = 0) debugOnly
	string logName = "BARD_ObjectsLocator"
	Debug.OpenUserLog(logName)
	return Debug.TraceUser(logName, "ModUpdater: " + asTextToPrint, aiSeverity)
endFunction