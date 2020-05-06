if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "Lovedones" )
	util.AddNetworkString("inLove")
	util.AddNetworkString("deathPopup")
	--AddCSLuaFile("Armor.lua")
else
	SWEP.PrintName = "Cupid's bow"
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
SWEP.ViewModelFOV = 120
SWEP.ViewModel = Model("models/weapons/cstrike/c_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")
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
lovedOnesArmor = {}
lovedones = {}
someoneDied = false
function SWEP:CreateGUI()
	if CLIENT then
		local ply = LocalPlayer()

		local w, h = 300, 195

		local Panel = vgui.Create("DFrame")
		--Panel:SetPaintBackground(false)
		Panel:SetSize(w, h)
		Panel:Center()
		Panel:MakePopup()
		Panel:IsActive()
		Panel:SetTitle("Love is in the air")
		Panel:SetVisible(true)
		Panel:ShowCloseButton(true)
		Panel:SetMouseInputEnabled(true)
		Panel:SetDeleteOnClose(true)
		Panel:SetKeyboardInputEnabled(false)

		local DLabel = vgui.Create("DLabel", Panel)
		DLabel:SetPos(10, 70)
		DLabel:SetSize(100, 20)
		DLabel:SetText("First Subject:")

		local NameComboBox = vgui.Create("DComboBox", Panel)
		NameComboBox:SetPos(130, 70)
		NameComboBox:SetSize(160, 20)
		NameComboBox:SetValue("Choose your first subject")

		local plys = player.GetAll()
		local value = ply:Name()

		local DLabel2 = vgui.Create("DLabel", Panel)
		DLabel2:SetPos(10, 95)
		DLabel2:SetSize(100, 20)
		DLabel2:SetText("Second Subject:")


		local NameComboBox2 = vgui.Create("DComboBox", Panel)
		NameComboBox2:SetPos(130, 95)
		NameComboBox2:SetSize(160, 20)
		NameComboBox2:SetValue("Choose your second subject")

		for i = 1, #plys do
			NameComboBox:AddChoice(plys[i]:Name(), plys[i])
			NameComboBox2:AddChoice(plys[i]:Name(), plys[i])
		end

		local FinishButton = vgui.Create("DButton", Panel)
		FinishButton:SetPos(100, 135)
		FinishButton:SetSize(100, 20)
		FinishButton:SetText("Finish")

		local data = 1
		
		self.GUI = Panel

		function FinishButton:DoClick()
			if NameComboBox:GetSelected()==nil or NameComboBox2:GetSelected()==nil then return true end	
			if NameComboBox:GetSelected()== NameComboBox2:GetSelected() then return true end
			for i = 1, #plys do
				if plys[i]:Name() == NameComboBox:GetSelected() then lovedOnesArmor[1]=plys[i] end
				if plys[i]:Name() == NameComboBox2:GetSelected() then lovedOnesArmor[2]=plys[i] end				
			end
			lovedOnesArmor[3] = LocalPlayer()
			net.Start("Lovedones")
				net.WriteTable(lovedOnesArmor)
			net.SendToServer()
			Panel:Close()
		end
	end
end

function SWEP:PrimaryAttack()
	if (not self.GUI or not self.GUI:IsValid()) && table.IsEmpty(lovedOnesArmor) then
		self:CreateGUI()
	end
	self.ReloadingTime = CurTime() + 0.2
	
	return true
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
	lovedOnesArmor = {}
	if lovedones[1]!=nil then
		lovedones[1].inLove = false
		lovedones[2].inLove = false
	end
	for k,v in next, player.GetAll() do 
		v.inLove = false
	end
	lovedones = {}
	hook.Remove("HUDPaint", "HUDPaint_DrawABox")
	hook.Remove("PreDrawHalos", "loversHalo")
	hook.Remove("TTTRenderEntityInfo", "ttt2_marker_highlight_players")
	if GetConVar("ttt_cupid_damage_split_enabled")==1 then hook.Remove('EntityTakeDamage', 'LoversDamageScalingBow') end
end)



net.Receive("Lovedones", function()	
	lovedones = net.ReadTable()
	if someoneDied then		
		if SERVER then
			lovedones[3]:StripWeapon("weapon_ttt2_cupidsbow")
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
				hook.Add('EntityTakeDamage', 'LoversDamageScalingBow', function(ply, dmginfo)
					if GetRoundState() ~= ROUND_ACTIVE then return end
					local attacker = dmginfo:GetAttacker()
					if not IsValid(attacker) or not attacker:IsPlayer() then return end				
					local damage = dmginfo:GetDamage()
					if ply==lovedones[1] or ply==lovedones[2] then
						lovedones[1]:TakeDamage(damage*0.5)
						lovedones[2]:TakeDamage(damage*0.5)
						dmginfo:ScaleDamage(0)
						return
					end
				end)
			end
			lovedones[3]:StripWeapon("weapon_ttt2_cupidsbow")
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