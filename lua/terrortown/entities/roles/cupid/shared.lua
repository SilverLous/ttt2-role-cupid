AddCSLuaFile()

if SERVER then
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_cup.vmt")
	CreateConVar("ttt_cupid_buyalbe_cupidscard", 1, {FCVAR_ARCHIVE}, "",0,1)
	CreateConVar("ttt_cupid_buyalbe_cupidscrossbow", 0, {FCVAR_ARCHIVE}, "",0,1)
	CreateConVar('ttt_cupid_damage_split_enabled', 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
end

function ROLE:PreInitialize()
	self.index = ROLE_CUPID
	self.color = Color(255, 20, 147, 255)
	self.abbr = 'cup'
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 2 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -16 -- multiplier for teamkill
	self.preventFindCredits = false
	self.preventKillCredits = true
	self.preventTraitorAloneCredits = false
	self.unknownTeam = true
	self.defaultTeam = TEAM_INNOCENT
	self.defaultEquipment = SPECIAL_EQUIPMENT
	self.fallbackTable = {}
	self.shopfallback = {ROLE_CUPID}
	if GetConVar("ttt_cupid_buyalbe_cupidscard"):GetBool() then
		table.insert(self.fallbackTable, {id = "weapon_ttt2_cupidsbow",material="",credits=1})
	end
	self.conVarData = {
		pct = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		credits = 1,
		minPlayers = 2, -- minimum amount of players until this role is able to get selected
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		random = 100
	}
end


-- init cupid fallback table
hook.Add("InitFallbackShops", "CupidInitFallback", function()
	-- init fallback shop
	print(table.ToString(CUPID.fallbackTable))
	InitFallbackShop(CUPID,CUPID.fallbackTable) -- merge jackal equipment with traitor equipment
end)

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

