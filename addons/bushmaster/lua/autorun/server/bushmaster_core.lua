BushMaster = {}
BushMaster.SoundTable = BushMaster.SoundTable or {}
BushMaster.Triggers = BushMaster.Triggers or {}

util.AddNetworkString("BushAction")

//resource.AddWorkshop( string workshopid ) bushmaster sounds

function BushMaster.RegisterTrigger(posStart,posEnd)
    print(posStart,posEnd)
    local uid = #BushMaster.Triggers+1
    local brush = ents.Create("bushtrigger")
	brush:SetNWVector("posmin", posStart)
	brush:SetNWVector("posmax", posEnd)
    brush:SetNWInt("bushid",uid)
    brush:SetPos(posStart,posEnd)
	brush:Spawn()
    BushMaster.Triggers[uid] = brush
    
end

function BushMaster.ReloadAll()

    for _,brush in pairs(ents.FindByClass("bushtrigger")) do
        local id = brush:GetNWInt("bushid")
        if(id) then
            BushMaster.Triggers[id] = nil
        end
        brush:Remove()
    end
    BushMaster.LoadBushTriggers()
end

function BushMaster.RemoveTrigger(uid)
    local brush = BushMaster.Triggers[uid]
    if(brush) then
        brush:Remove()
        BushMaster.Triggers[uid] = nil
    end
end

net.Receive("BushAction", function(len,ply)
    local action = net.ReadUInt(3)
    if(action==BUSH_CREATE)then
        if(CAMI.PlayerHasAccess(ply, "Bushmaster - Create Bush", nil)) then
            local posStart = net.ReadVector()
            local posEnd = net.ReadVector()
            BushMaster.RegisterTrigger(posStart,posEnd)
            
            BushMaster.SaveBushTriggers()
            BushMaster.ReloadAll()
        end
    end
    if(action==BUSH_REMOVE)then
        if(CAMI.PlayerHasAccess(ply, "Bushmaster - Remove Bush", nil)) then
            local toRemove = net.ReadUInt(10)
            BushMaster.RemoveTrigger(toRemove)
            BushMaster.SaveBushTriggers()
        end
    end
    
end)


function BushMaster.SaveBushTriggers()
    local bushes = ents.FindByClass("bushtrigger")
    local saveTable = {}
    for _,v in pairs(bushes) do
        saveTable[#saveTable+1] = {
            posMin = v:GetNWVector("posmin"),
	        posMax = v:GetNWVector("posmax")
        }
    end
    saveTable = util.TableToJSON(saveTable)
    file.Write("bushmaster_"..game.GetMap()..".txt",saveTable)
end

function BushMaster.LoadBushTriggers()
    local infoTable = file.Read( "bushmaster_"..game.GetMap()..".txt", "DATA" )
    if(infoTable) then
        infoTable = util.JSONToTable(infoTable)
        for k,v in pairs(infoTable) do
            if(v.posMin and v.posMax) then
                BushMaster.RegisterTrigger(v.posMin,v.posMax)
            end
        end
    end
end

function BushMaster.AddSound(path) 
    if(isstring(path)) then
        BushMaster.SoundTable[#BushMaster.SoundTable+1] = path
    else
       
        ErrorNoHalt("Not valid sound path! Check you configuration file!","Type:", print(type(path)))
    end
end

include( "bushmaster/bushmaster_config.lua" )

hook.Add( "PlayerAuthed", "LoadBushes", function()
    BushMaster.ReloadAll()
end)