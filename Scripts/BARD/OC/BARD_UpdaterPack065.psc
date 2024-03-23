Scriptname BARD:OC:BARD_UpdaterPack065 extends BARD:OC:BARD_UpdaterPack

function ProcessUpdate()
    ; Yeah I know

    Trace("Process Update on " + self)

    BARD:OC:BARD_LocatorsStarCorePackData packData = Packages[0] as BARD:OC:BARD_LocatorsStarCorePackData
    GlobalVariable objGlobal = NONE
    BARD:OC:BARD_LocatorsPackData:ObjectiveTarget target = NONE

    packData.ObjectivesGlobal = new GlobalVariable[0]
    
    objGlobal = Game.GetFormFromFile(0x0004CBD0, RequiredDLC) as GlobalVariable
    packData.ObjectivesGlobal.Add(objGlobal)

    objGlobal = Game.GetFormFromFile(0x0004CBD2, RequiredDLC) as GlobalVariable
    packData.ObjectivesGlobal.Add(objGlobal)

    ; Exterior

    Trace("Setting up " + packData.PackName)
    
    ; Nuka-Galaxy - SIT
    packData = Packages[1] as BARD:OC:BARD_LocatorsStarCorePackData
    Trace("Setting up " + packData.PackName)

    packData.ObjectivesGlobal = new GlobalVariable[0]

    objGlobal = Game.GetFormFromFile(0x0004CBD1, RequiredDLC) as GlobalVariable
    packData.ObjectivesGlobal.Add(objGlobal)

    objGlobal = Game.GetFormFromFile(0x0004CBD3, RequiredDLC) as GlobalVariable
    packData.ObjectivesGlobal.Add(objGlobal)

    ; RobCo - Vault-Tec
    packData = Packages[2] as BARD:OC:BARD_LocatorsStarCorePackData
    Trace("Setting up " + packData.PackName)

    packData.ObjectivesGlobal = new GlobalVariable[0]

    objGlobal = Game.GetFormFromFile(0x0004CBCF, RequiredDLC) as GlobalVariable
    packData.ObjectivesGlobal.Add(objGlobal)

    objGlobal = Game.GetFormFromFile(0x0004CBD4, RequiredDLC) as GlobalVariable
    packData.ObjectivesGlobal.Add(objGlobal)

    Trace("Finished Update Process for 0.6.5")

    Disable(true)
endFunction