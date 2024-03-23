Scriptname BARD:OC:BARD_UpdaterPack extends Quest

; Very important. Use 1 updater per WorldSpace per update

Quest[] Property Packages Auto

Quest Property ModUpdater Auto

String Property RequiredDLC = "" Auto

Float Property Version Auto Const

event OnQuestInit()
    if(!CanBeInstalled())
        Trace("Updated could not be installed")
        Stop()
    endif

    BARD:OC:BARD_ModUpdater updater = ModUpdater as BARD:OC:BARD_ModUpdater

    updater.AddUpdater(self, Version)

    Trace("Sending Packages: " + Packages.Length)
    updater.AddPackData(Packages, Version)
endEvent

bool function CanBeInstalled()
    if(RequiredDLC == "")
        return true
    endif
    Trace("Requires DLC: " + RequiredDLC)
    return Game.IsPluginInstalled(RequiredDLC)
endFunction

function ProcessUpdate()
    ; In case some code needs to be called to fix something on the previous versions
    
    Trace("Finished Update Process")
    
    Disable(true)
endFunction

function Disable(bool stop)
    UnregisterForAllEvents()
    if(stop)
        ModUpdater = NONE
        Packages.Clear()
        Packages = NONE

        Stop()
    endif
endFunction

bool function Trace(string asTextToPrint, int aiSeverity = 0) debugOnly
	string logName = "BARD_ObjectsLocator"
	Debug.OpenUserLog(logName)
	return Debug.TraceUser(logName, "UpdaterPack: " + asTextToPrint, aiSeverity)
endFunction