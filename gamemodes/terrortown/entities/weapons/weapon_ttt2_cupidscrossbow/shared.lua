if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "Lovedones" )
	util.AddNetworkString("inLove")
	util.AddNetworkString("deathPopup")
	--AddCSLuaFile("Armor.lua")
    
else
	SWEP.PrintName = "Cupid's crossbow"
	SWEP.Author = "SilverLous"

	SWEP.Slot = 7
end

SWEP.LoadoutFor = {ROLE_CUPID}
SWEP.HoldType = "normal"
SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_NONE
SWEP.WeaponID = AMMO_BODYSPAWNER

SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 70
SWEP.ViewModel = Model("models/weapons/c_crossbow.mdl")
SWEP.WorldModel = Model("models/weapons/w_crossbow.mdl")
SWEP.CanBuy = { ROLE_CUPID }

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
lovedones = {}
someoneDied = false

lover1=""

function SWEP:PrimaryAttack()
	trace = self.Owner:GetEyeTrace().Entity
	if IsValid(trace) && IsPlayer(trace) then
		if lover1=="" then
			lover1 = trace
			tempOwner =self.Owner
			if CLIENT && LocalPlayer()==tempOwner then 
				LocalPlayer():GetActiveWeapon():ShootEffects()
				LocalPlayer():GetActiveWeapon():ShootBullet(0,10, 1)
				EPOP:AddMessage(
					{
					text = LANG.GetTranslation("crossBow_title")..lover1:Nick().."!",
					color = Color(255, 20, 147, 255)
					},
				LANG.GetTranslation("crossBow_text"),
				6
				)
				if GetConVar("ttt_cupid_forced_selflove"):GetBool() then
					net.Start("Lovedones")
						net.WriteTable({tempOwner,lover1,tempOwner})
					net.SendToServer()
				end
			end
			self.CanAimSelf = true
		else
			if lover1 ~= trace && CLIENT && LocalPlayer()==tempOwner then
				LocalPlayer():GetActiveWeapon():ShootEffects()
				LocalPlayer():GetActiveWeapon():ShootBullet(0,10, 1)
				net.Start("Lovedones")
					net.WriteTable({trace,lover1,tempOwner})
				net.SendToServer()
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
			net.WriteTable({tempOwner,lover1,tempOwner})
		net.SendToServer()
	end
end

function SWEP:OnDrop()
	self:Remove()
end
