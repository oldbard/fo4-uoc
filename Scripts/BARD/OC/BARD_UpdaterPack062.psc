Scriptname BARD:OC:BARD_UpdaterPack062 extends BARD:OC:BARD_UpdaterPack

Quest Property Manager Auto

BARD:OC:BARD_LocatorsManager _locatorsManager

function ProcessUpdate()
    ; Yeah I know

    Trace("Process Update on " + self)

    ; Magazines
    BARD:OC:BARD_LocatorsPackData packData = Packages[0] as BARD:OC:BARD_LocatorsPackData
    
    packData.ObjectivesTargets[0].TargetCell = Game.GetFormFromFile(0x00003297, RequiredDLC) as Cell
    packData.ObjectivesTargets[0].FormID = Game.GetFormFromFile(0x0002A9F3, RequiredDLC) as Form

    packData.ObjectivesTargets[1].FormID = Game.GetFormFromFile(0x0002A9F4, RequiredDLC) as Form

    packData.ObjectivesTargets[2].TargetCell = Game.GetFormFromFile(0x0001951D, RequiredDLC) as Cell
    packData.ObjectivesTargets[2].FormID = Game.GetFormFromFile(0x0002A9F5, RequiredDLC) as Form

    packData.ObjectivesTargets[4].TargetCell = Game.GetFormFromFile(0x000139D2, RequiredDLC) as Cell
    packData.ObjectivesTargets[4].FormID = Game.GetFormFromFile(0x0002A9F6, RequiredDLC) as Form

    packData.ObjectivesTargets[6].FormID = Game.GetFormFromFile(0x0002A9F7, RequiredDLC) as Form


    ; Power Armors
    packData = Packages[1] as BARD:OC:BARD_LocatorsPackData
    
    packData.ObjectivesTargets[6].TargetCell = Game.GetFormFromFile(0x0001951E, RequiredDLC) as Cell
    packData.ObjectivesTargets[8].TargetCell = Game.GetFormFromFile(0x00008B57, RequiredDLC) as Cell
    packData.ObjectivesTargets[10].TargetCell = Game.GetFormFromFile(0x0000805B, RequiredDLC) as Cell


    ; PA Leveled 01
    _locatorsManager = Manager as BARD:OC:BARD_LocatorsManager

    packData = _locatorsManager.Packages[15] as BARD:OC:BARD_LocatorsPackData

    packData.ObjectivesTargets[4].TargetCell = Game.GetFormFromFile(0x00054BE9, "Fallout4.esm") as Cell
    
    Quest[] additional = _locatorsManager.GetAdditionalQuests()

    ; Heavy Weapons
    packData = additional[2] as BARD:OC:BARD_LocatorsPackData
    
    packData.ObjectivesTargets[3].TargetCell = Game.GetFormFromFile(0x00054BE9, "Fallout4.esm") as Cell
    packData.ObjectivesTargets[18].TargetCell = Game.GetFormFromFile(0x00054BE9, "Fallout4.esm") as Cell

    Trace("Finished Update Process for 0.6.2")

    Manager = NONE
    _locatorsManager = NONE

    Disable(true)
endFunction