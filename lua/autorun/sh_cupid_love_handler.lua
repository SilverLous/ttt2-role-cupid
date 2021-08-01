
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
	hook.Remove("Tick", "Lovers_Heal_Share")
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
            lovedones[1]:ChatPrint("You are now in Team Lovers")
            lovedones[2]:UpdateTeam(TEAM_CUPID)
            lovedones[2]:ChatPrint("You are now in Team Lovers")
			PrintMessage(HUD_PRINTCONSOLE, lovedones[1]:Nick().." is now in love with "..lovedones[2]:Nick()..".")
            
            if GetConVar("ttt_cupid_joins_team_lovers"):GetBool() then                      
                lovedones[3]:UpdateTeam(TEAM_CUPID)
				lovedones[3]:ChatPrint("You are now in Team Lovers")
            end            
		end
		if GetConVar("ttt_cupid_joins_team_lovers"):GetBool() && lovedones[1]:GetTeam() ~= lovedones[3]:GetTeam() then   
			lovedones[3]:UpdateTeam(lovedones[1]:GetTeam())
            lovedones[3]:ChatPrint("You are now in Team " .. tostring(lovedones[1]:GetTeam()))
			PrintMessage(HUD_PRINTCONSOLE, lovedones[3]:Nick().." is now also in on it.")
		end
		SendFullStateUpdate()
		net.Start("inLove")
			net.WriteTable({lovedones[1],lovedones[2],lovedones[3]})
		net.Send({lovedones[1],lovedones[2],lovedones[3]})
		lovedones[1].inLove = true
		lovedones[2].inLove = true
		if SERVER then
			if GetConVar("ttt_cupid_damage_split_enabled"):GetBool()==true then
				hook.Add('EntityTakeDamage', 'LoversDamageScaling', function(ply, dmginfo)
					if GetRoundState() ~= ROUND_ACTIVE then return end
					local attacker = dmginfo:GetAttacker()
					--if not IsValid(attacker) or not attacker:IsPlayer() then return end				
					local damage = dmginfo:GetDamage()
					if ply.inLove then
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
				end)			
				hook.Add("Tick", "Lovers_Heal_Share",function()
					if CurTime()%1 == 0 && lovedones[1]:Alive() && lovedones[2]:Alive() && lovedones[1]:Health() != lovedones[2]:Health() then 
						healthDiff = lovedones[1]:Health()-lovedones[2]:Health()
						if healthDiff>0 then
							lovedones[2]:SetHealth(lovedones[1]:Health())
						else
							lovedones[1]:SetHealth(lovedones[2]:Health())
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
		if LocalPlayer() == lovedones[1] or LocalPlayer() == lovedones[2] then
			if GetConVar("ttt_cupid_joins_team_lovers"):GetBool() && LocalPlayer() ~= lovedones[1] && LocalPlayer() ~= lovedones[2] && LocalPlayer() == lovedones[3] then
				EPOP:AddMessage(
					{
					text = LANG.GetTranslation("inLovePop_cup_title"),
					color = Color(255, 20, 147, 255)
					},
				LANG.GetTranslation("inLovePop_cup_text")..LocalPlayer():GetTeam(),
				6
				)
			else
				EPOP:AddMessage(
					{
					text = LANG.GetTranslation("inLovePop_title")..Ply:Nick(),
					color = Color(255, 20, 147, 255)
					},
				LANG.GetTranslation("inLovePop_text")..LocalPlayer():GetTeam(),
				6
				)
			end
			
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