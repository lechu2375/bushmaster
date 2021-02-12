local PANEL = {}
BushMaster = BushMaster or {}
function PANEL:Init()
    BushMaster.GUI = self
    local x,y = ScrW()/3,ScrH()
    local aspect = ScrW()/ScrH() //In most cases 16:9 ~ 1.77777777778
    y=x/aspect //xd
    self:SetSize(x,y)
    self:Center()
    self:MakePopup()
    self:SetTitle("Bushmaster")
    self:ShowCloseButton(true)
    self.list = self:Add("DScrollPanel")
    self.list:Dock(FILL)

end


function PANEL:Populate(infoTable)
    for k,v in pairs(infoTable) do
        local bushPanel = self.list:Add("DPanel")
        bushPanel:Dock(TOP)
        bushPanel:SetHeight(self:GetTall()/6)
        bushPanel:SetDrawBackground(false)
        local button = bushPanel:Add("BushMasterButton")
        button:SetText("REMOVE ID:"..k)
        button:SetFont("DermaLarge")
        button:Dock(FILL)
        button:DockMargin(5, 10, 5, 0)
        button.DoClick = function()
            net.Start("BushAction")
                net.WriteUInt(BUSH_REMOVE,3)
                net.WriteUInt(k,10)
            net.SendToServer()
            bushPanel:Remove()
        end
    end

end

function PANEL:Paint(w,h)
	surface.SetDrawColor(44, 62, 80)
	surface.DrawRect(0, 0,w,h)
end

concommand.Add("eoooddychac", function()
    local panel = vgui.Create("BushMasterGUI")
    local bushTable = {}
    for _,v in pairs(ents.FindByClass("bushtrigger")) do
        bushTable[v:GetNWInt("bushid")] = v
    end
    panel:Populate(bushTable)
end)

vgui.Register("BushMasterGUI",PANEL,"DFrame")

PANEL = {}
local red = Color(192, 57, 43)
local thickness = 4
function PANEL:Paint(w,h)
	surface.SetDrawColor(color_white)
	surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(red)

    surface.DrawRect(0,0,50,thickness)
    surface.DrawRect(0,0,thickness,50)

    surface.DrawRect(w-50,h-thickness,50,thickness)
    surface.DrawRect(w-thickness,0,thickness,50)

end

vgui.Register("BushMasterButton",PANEL,"DButton")