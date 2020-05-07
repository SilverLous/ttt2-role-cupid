
lovedones = {}
someoneDied = false

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
			lovedones[3]:StripWeapon("weapon_ttt2_cupidsbow")
		end
    else				
        if (lovedones[1]:GetTeam() != lovedones[2]:GetTeam() or GetConVar("ttt_cupid_lovers_force_own_team"):GetBool() ) then
            lovedones[1]:UpdateTeam(TEAM_CUPID)
            lovedones[2]:UpdateTeam(TEAM_CUPID)
            
            if GetConVar("ttt_cupid_joins_team_lovers"):GetBool() then                      
                lovedones[3]:UpdateTeam(TEAM_CUPID)
            end
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
						if ( not m_bApplyingDamage and GetConVar("ttt_cupid_joins_team_lovers"):GetBool() and lovedones[1]~=lovedones[3] and lovedones[2]~=lovedones[3] ) then
							m_bApplyingDamage = true
							dmginfo:SetDamage(dmginfo:GetDamage() / 3)
							lovedones[1]:TakeDamageInfo( dmginfo )
							lovedones[2]:TakeDamageInfo( dmginfo )
							lovedones[3]:TakeDamageInfo( dmginfo )
							dmginfo:ScaleDamage(0)
							m_bApplyingDamage = false
							return
                        else
                            if ( not m_bApplyingDamage) then                            
                                m_bApplyingDamage = true
                                dmginfo:SetDamage(dmginfo:GetDamage() / 2)
                                lovedones[1]:TakeDamageInfo( dmginfo )
                                lovedones[2]:TakeDamageInfo( dmginfo )
                                dmginfo:ScaleDamage(0)
                                m_bApplyingDamage = false
                                return
                            end
                        end
					end
				end)
			end
			lovedones[3]:StripWeapon("weapon_ttt2_cupidscrossbow")
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