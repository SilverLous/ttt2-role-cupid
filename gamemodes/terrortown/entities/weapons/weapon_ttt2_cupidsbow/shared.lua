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

SWEP.HoldType = "normal"
SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_NONE

SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 120
SWEP.ViewModel = Model("models/weapons/cstrike/c_c4.mdl")
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
			if not plys[i]:GetSubRoleData().isPublicRole then

				NameComboBox:AddChoice(plys[i]:Name(), plys[i])
				NameComboBox2:AddChoice(plys[i]:Name(), plys[i])
			end
		end

		local FinishButton = vgui.Create("DButton", Panel)
		FinishButton:SetPos(100, 135)
		FinishButton:SetSize(100, 20)
		FinishButton:SetText("Finish")

		local data = 1
		
		self.GUI = Panel

		function FinishButton:DoClick()
			lovedOnesArmor = {}
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
	if (not self.GUI or not self.GUI:IsValid()) then
		self:CreateGUI()
	end
	self.ReloadingTime = CurTime() + 0.2
	
	return true
end


function SWEP:OnDrop()
	self:Remove()
end
