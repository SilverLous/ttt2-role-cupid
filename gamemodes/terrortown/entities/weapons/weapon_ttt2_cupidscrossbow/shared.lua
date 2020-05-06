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
			end
			self.CanAimSelf = true
		else
			print("First")
			if lover1 ~= trace && CLIENT && LocalPlayer()==tempOwner then
				LocalPlayer():GetActiveWeapon():ShootEffects()
				LocalPlayer():GetActiveWeapon():ShootBullet(0,10, 1)
				print(trace:Nick(),lover1:Nick())
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

hook.Add("PlayerDeath", "loveSick", function(player,item,killer)
	someoneDied = true	
	if SERVER then
				
		if lovedones[1] == player and player.inLove then
			LANG.Msg(player, "deathPopup_title")
			net.Start("deathPopup")
			net.Send(lovedones[2])
			timer.Simple(5, function()
				if !table.IsEmpty(lovedones) then lovedones[2]:TakeDamage(200,killer,self) end
			end)
		end
		if lovedones[2] == player and player.inLove then
			LANG.Msg(player, "deathPopup_title")
			net.Start("deathPopup")
			net.Send(lovedones[1])
			timer.Simple(5, function()
				if !table.IsEmpty(lovedones) then lovedones[1]:TakeDamage(200,killer,self) end
			end)
		end
	end
end)	

hook.Add("TTTPrepareRound","reseeeettime",function()		
	someoneDied = false
	lover1 = ""
	if lovedones[1]!=nil then
		lovedones[1].inLove = false
		lovedones[2].inLove = false
	end
	for k,v in next, player.GetAll() do 
		v.inLove = false
	end
	lovedones = {}
	m_bApplyingDamage = false
	hook.Remove("HUDPaint", "HUDPaint_DrawABox")
	hook.Remove("PreDrawHalos", "loversHalo")
	hook.Remove("TTTRenderEntityInfo", "ttt2_marker_highlight_players")
	--self.CanAimSelf = false
	if GetConVar("ttt_cupid_damage_split_enabled")==1 then hook.Remove('EntityTakeDamage', 'LoversDamageScaling') end
end)



net.Receive("Lovedones", function()	
	lovedones = net.ReadTable()
	if someoneDied then		
		if SERVER then
			lovedones[3]:StripWeapon("weapon_ttt2_cupidscrossbow")
		end
	else				
		if (lovedones[1]:GetTeam() != lovedones[2]:GetTeam()) then
			lovedones[1]:UpdateTeam(TEAM_CUPID)
			lovedones[2]:UpdateTeam(TEAM_CUPID)
			SendFullStateUpdate()
		end
		net.Start("inLove")
			net.WriteTable({lovedones[1],lovedones[2]})
		net.Send({lovedones[1],lovedones[2]})
		lovedones[1].inLove = true
		lovedones[2].inLove = true
		if SERVER then
			if GetConVar("ttt_cupid_damage_split_enabled"):GetBool()==true then
				hook.Add('EntityTakeDamage', 'LoversDamageScaling', function(ply, dmginfo)
					if GetRoundState() ~= ROUND_ACTIVE then return end
					local attacker = dmginfo:GetAttacker()
					if not IsValid(attacker) or not attacker:IsPlayer() then return end				
					local damage = dmginfo:GetDamage()
					if ply.inLove then
						if ( not m_bApplyingDamage ) then
							m_bApplyingDamage = true
							dmginfo:SetDamage(dmginfo:GetDamage() / 2)
							lovedones[1]:TakeDamageInfo( dmginfo )
							lovedones[2]:TakeDamageInfo( dmginfo )
							dmginfo:ScaleDamage(0)
							m_bApplyingDamage = false
							return
						end
					end
				end)
			end
			lovedones[3]:StripWeapon("weapon_ttt2_cupidscrossbow")
		end
	end

end)
net.Receive("inLove", function()
	if CLIENT then
		lovedones = net.ReadTable()
		lovedones[1].inLove = true
		lovedones[2].inLove = true
		if  LocalPlayer() == lovedones[1] then Ply=lovedones[2] else Ply=lovedones[1] end
		EPOP:AddMessage(
			{
			text = LANG.GetTranslation("inLovePop_title")..Ply:Nick(),
			color = Color(255, 20, 147, 255)
			},
		LANG.GetTranslation("inLovePop_text")..LocalPlayer():GetTeam(),
		6
		)
		hook.Add("PreDrawHalos", "loversHalo", function()
			if Ply:Alive() then
				outline.Add(Ply, Color(255, 20, 147, 255), OUTLINE_MODE_VISIBLE)
			end
		end)
		hook.Add("TTTRenderEntityInfo", "ttt2_marker_highlight_players", function(tData)		
			local ent = tData:GetEntity()		
			-- has to be a player
			if not ent:IsPlayer() then return end
			
			if not ent.inLove then return end
		
			if !LocalPlayer().inLove then return end
		
			tData:AddDescriptionLine(
				LANG.GetTranslation("hoverLove"),
				Color(255, 20, 147, 255)
			)
		
			tData:AddIcon(
				Material("vgui/ttt/dynamic/roles/icon_lov"),
				Color(255, 20, 147, 255)
			)
		end)
	end
end)

net.Receive("deathPopup", function()
	if CLIENT then
		deathtimer=CurTime()
		EPOP:AddMessage(
			{
			text = LANG.GetTranslation("deathPopup_title"),
			color = Color(20, 20, 20, 255)
			},
		LANG.GetTranslation("deathPopup_text"),
		6
		)
	end
end)