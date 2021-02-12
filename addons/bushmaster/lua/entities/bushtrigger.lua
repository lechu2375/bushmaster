AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Initialize()

	self.posmin = self:GetNWVector("posmin")
	self.posmax = self:GetNWVector("posmax")

	self.centerPos = LerpVector(0.5,self.posmin,self.posmax)
	self:SetNWVector("center",self.centerPos)

	self:InitCollision()
	if(SERVER)then
		self:SetTrigger(true)
	end
end



function ENT:InitCollision()

	self.posmin = self:GetNWVector("posmin")
	self.posmax = self:GetNWVector("posmax")
	self:DrawShadow(false)
	self:SetCollisionBoundsWS(self.posmin,self.posmax)

	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(0)
	self:SetCustomCollisionCheck(true)
    self:SetSolidFlags(FSOLID_MAX_BITS)

	self.centerPos = LerpVector(0.5,self.posmin,self.posmax)
	self:SetNWVector("center",self.centerPos)


end




if(CLIENT) then
	function ENT:Draw()
		if( !IsValid(LocalPlayer():GetActiveWeapon()) ) then return end
		if( !(LocalPlayer():GetActiveWeapon():GetClass()=="bushmaker") ) then return end
		local cboundf, cbounds = self:GetCollisionBounds()


		render.DrawWireframeBox(self:GetPos(),angle_zero,cboundf,cbounds,color_white,false)
		local textPos = self.centerPos:ToScreen()
	
		
		cam.Start2D()
			
			draw.SimpleText(string.format("BushID: %s", self:GetNWVector("bushid")), "DermaDefault", textPos.x, textPos.y, color_white )
			
		cam.End2D()

		
	end
end






function ENT:Touch(ent)
	if(ent.bushdelay)then
		if(ent.bushdelay<CurTime())then
			local vel = math.abs(ent:GetAbsVelocity().x)+math.abs(ent:GetAbsVelocity().y)
			if(vel>10) then
				local bSprint = ent:IsSprinting()
				local snd = table.Random(BushMaster.SoundTable)
				if(ent.lastbushsnd and ent.lastbushsnd==snd and #BushMaster.SoundTable>1) then
					while(ent.lastbushsnd==snd) do
						snd = table.Random(BushMaster.SoundTable)
					end
				end
				local sndLevel = 55
				if(bSprint) then
					sndLevel = sndLevel + (BushMaster.SndLvlModifier or 0)
				end
				ent.lastbushsnd = snd	

				ent:EmitSound(snd,sndLevel,100,1)
				ent.bushdelay=CurTime()+BushMaster.SndDelay
			end
		end
	else
		ent.bushdelay=CurTime()+BushMaster.SndDelay
	end
end

function ENT:KeyValue( key, value )
end
function ENT:EndTouch(ply)
	if(ply:IsPlayer() and ply.lastbushsnd) then
		ply:EmitSound(ply.lastbushsnd,.05,100,0,CHAN_AUTO,1,8) //fade out sound
	end
end
function ENT:OnRemove()
end

function ENT:AcceptInput( inputName, activator, called, data )
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end




hook.Add("ShouldCollide", "bush.detect", function(a, b)
   
	if a:GetClass() == "bushtrigger" then
		return false
	end

end)




