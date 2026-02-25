if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "Lovedones" )
	util.AddNetworkString("inLove")
	util.AddNetworkString("deathPopup")
	util.AddNetworkString("betrayedTraitor")
	--AddCSLuaFile("Armor.lua")
    
else
	SWEP.PrintName = "Cupid's crossbow"
	SWEP.Author = "SilverLous"

	SWEP.Slot = 7
end


SWEP.HoldType = "normal"
SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_NONE

SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 70
SWEP.ViewModel = Model("models/weapons/c_crossbow.mdl")
SWEP.WorldModel = Model("")

SWEP.DrawCrosshair = false
SWEP.ViewModelFlip = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.1
SWEP.AllowDrop = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 0.1

SWEP.NoSights = true

SWEP.CanAimSelf = false

SWEP.lover1=""

function SWEP:PrimaryAttack()
	trace = self.Owner:GetEyeTrace().Entity
	if IsValid(trace) && IsPlayer(trace) then
		if trace:GetSubRoleData().isPublicRole then	
			local role_name = trace:GetSubRoleData().name
			if CLIENT then		
				EPOP:AddMessage(
					{
					text = role_name:sub(1,1):upper()..role_name:sub(2) .. LANG.GetTranslation("detectives_not_allowed"),
					color = Color(255, 20, 147, 255)
					},
					"",
					6)		
			end
		else
			if self.lover1=="" then
				self.lover1 = trace
				tempOwner =self.Owner
				if CLIENT && LocalPlayer()==tempOwner then 
					LocalPlayer():GetActiveWeapon():ShootEffects()
					LocalPlayer():GetActiveWeapon():ShootBullet(0,10, 1)
					EPOP:AddMessage(
						{
						text = LANG.GetTranslation("crossBow_title")..self.lover1:Nick().."!",
						color = Color(255, 20, 147, 255)
						},
					LANG.GetTranslation("crossBow_text"),
					6
					)
					if GetConVar("ttt_cupid_forced_selflove"):GetBool() then
						net.Start("Lovedones")
							net.WriteTable({tempOwner,self.lover1,tempOwner})
						net.SendToServer()
					end
				end
				self.CanAimSelf = true
			else
				if self.lover1 ~= trace && CLIENT && LocalPlayer()==tempOwner then
					LocalPlayer():GetActiveWeapon():ShootEffects()
					LocalPlayer():GetActiveWeapon():ShootBullet(0,10, 1)
					net.Start("Lovedones")
						net.WriteTable({trace,self.lover1,tempOwner})
					net.SendToServer()
				end
			end
		end

	end
	self.ReloadingTime = CurTime() + 0.2
	
	return true
end

function SWEP:SecondaryAttack()
	if not self.CanAimSelf then return end
	self.CanAimSelf = false
	tempOwner =self.Owner
	if CLIENT && LocalPlayer()==tempOwner then 
		net.Start("Lovedones")
			net.WriteTable({tempOwner,self.lover1,tempOwner})
		net.SendToServer()
	end
end

function SWEP:OnDrop()
	self:Remove()
end
