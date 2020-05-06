AddCSLuaFile()

if SERVER then
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_cup.vmt")
	--include("terrortown/entities/weapons/weapon_ttt2_cupidsbow")
end

function ROLE:PreInitialize()
	self.index = ROLE_CUPID
	self.color = Color(255, 20, 147, 255)
	self.abbr = 'cup'
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 2 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -32 -- multiplier for teamkill
	self.preventFindCredits = true
	self.preventKillCredits = true
	self.preventTraitorAloneCredits = true
	self.unknownTeam = true
	self.defaultTeam = TEAM_INNOCENT

	self.conVarData = {
		pct = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 6, -- minimum amount of players until this role is able to get selected
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		random = 33
	}
end

roles.InitCustomTeam(ROLE.name, { -- this creates the var "TEAM_CUPID"
		icon = "vgui/ttt/dynamic/roles/icon_lov",
		color = Color(255, 20, 147, 255)
})

if SERVER then
	-- Give Loadout on respawn and rolechange
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		ply:GiveEquipmentWeapon("weapon_ttt2_cupidsbow")
	end
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		ply:StripWeapon("weapon_ttt2_cupidsbow")
	end
end

