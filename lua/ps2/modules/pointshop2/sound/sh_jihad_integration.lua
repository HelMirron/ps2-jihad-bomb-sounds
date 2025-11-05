-- Jihad Bomb Sound Integration
-- Hooks into EntityEmitSound to replace jihad bomb sounds with custom sounds

Pointshop2.JihadIntegration = {}

local playerSoundCache = {}

-- Preview sound tracking to prevent hook interference
local previewSounds = {}
local PREVIEW_SOUND_DURATION = 5 -- Seconds to track preview sounds

-- Mark a sound as preview-only (client-side)
-- This prevents the EntityEmitSound hook from broadcasting it
function Pointshop2.JihadIntegration.MarkAsPreviewSound( soundPath )
	if not soundPath or soundPath == "" then return end
	
	local cleanPath = soundPath:gsub( "^sound/", "" ):lower()
	previewSounds[cleanPath] = CurTime() + PREVIEW_SOUND_DURATION
end

-- Check if a sound is currently marked as preview
function Pointshop2.JihadIntegration.IsPreviewSound( soundPath )
	if not soundPath or soundPath == "" then return false end
	
	local cleanPath = soundPath:gsub( "^sound/", "" ):lower()
	local expireTime = previewSounds[cleanPath]
	
	if expireTime and CurTime() < expireTime then
		return true
	end
	
	-- Cleanup expired entry
	if expireTime then
		previewSounds[cleanPath] = nil
	end
	
	return false
end

-- Get player's equipped jihad sound from database
function Pointshop2.JihadIntegration.GetPlayerJihadSound( player )
	if not IsValid( player ) then return nil end
	
	local cachedSound = playerSoundCache[player:SteamID()]
	if cachedSound and CurTime() - cachedSound.cachedAt < 3600 then
		return cachedSound.sound
	end
	
	if SERVER then
		Pointshop2.SoundItemPersistence.findWhere{ ownerID = player:UserID() }
		:Then( function( sounds )
			if #sounds > 0 then
				local sound = sounds[1]
				playerSoundCache[player:SteamID()] = {
					sound = sound,
					cachedAt = CurTime()
				}
				return sound
			end
			return nil
		end )
		:Fail( function( err )
			KLogf( 2, "[Pointshop2 Sounds] Error fetching player sound: %s", tostring( err ) )
		end )
	end
	
	return nil
end

-- Get custom sound path or fall back to default
function Pointshop2.JihadIntegration.GetCustomOrDefaultJihadSound( player )
	local customSound = Pointshop2.JihadIntegration.GetPlayerJihadSound( player )
	
	if customSound and customSound.soundPath and customSound.soundPath ~= "" then
		local cleanPath = customSound.soundPath:gsub( "^sound/", "" )
		local fullPath = "sound/" .. cleanPath
		if file.Exists( fullPath, "GAME" ) then
			return cleanPath
		else
			KLogf( 2, "[Pointshop2 Sounds] Sound file not found: %s", fullPath )
		end
	end
	
	return "physics/weapons/bomb_stick/bomb_stick_impact_concrete1.wav"
end

-- Set player's custom sound (called on equip)
function Pointshop2.JihadIntegration.SetPlayerSound( player, item )
	if not IsValid( player ) then return end
	
	if SERVER then
		if item.soundPath and item.soundPath ~= "" then
			util.PrecacheSound( item.soundPath )
		end
		
		playerSoundCache[player:SteamID()] = nil
		
		net.Start( "PS2_SoundSet" )
		net.WriteEntity( player )
		net.WriteString( item.soundPath or "" )
		net.SendPVS( player:GetPos() )
	end
end

-- Network strings
if SERVER then
	util.AddNetworkString( "PS2_SoundSet" )
	util.AddNetworkString( "PS2_SoundUpdate" )
else
	net.Receive( "PS2_SoundSet", function( len )
		local player = net.ReadEntity()
		local soundPath = net.ReadString()
		
		if IsValid( player ) then
			playerSoundCache[player:SteamID()] = {
				sound = { soundPath = soundPath },
				cachedAt = CurTime()
			}
		end
	end )
end

-- EntityEmitSound hook to replace jihad bomb sounds
hook.Add( "EntityEmitSound", "PS2_JihadSoundOverride", function( data )
	local soundPath = data.SoundName or ""
	soundPath = soundPath:lower()
	
	-- CRITICAL: Ignore preview sounds to prevent global broadcast
	-- Preview sounds should only play locally for the user who clicked the button
	if Pointshop2.JihadIntegration.IsPreviewSound( soundPath ) then
		return false -- Don't modify preview sounds
	end
	
	-- Get player from sound entity
	local player = nil
	if IsValid(data.Entity) then
		if data.Entity:IsPlayer() then
			player = data.Entity
		elseif data.Entity:IsWeapon() and IsValid(data.Entity:GetOwner()) then
			player = data.Entity:GetOwner()
		elseif IsValid(data.Entity:GetOwner()) and data.Entity:GetOwner():IsPlayer() then
			player = data.Entity:GetOwner()
		end
	end
	
	if not IsValid(player) then return end
	
	-- Check if player has custom sound equipped
	local customSoundPath = nil
	
	-- Method 1: Check cache (fast)
	local cachedSound = playerSoundCache[player:SteamID()]
	if cachedSound and cachedSound.sound and cachedSound.sound.soundPath and cachedSound.sound.soundPath ~= "" then
		customSoundPath = cachedSound.sound.soundPath
	end
	
	-- Method 2: Check equipped items directly (reliable)
	if not customSoundPath and player.PS2_Slots then
		for slotId, slot in pairs(player.PS2_Slots) do
			local item = slot.Item or slot
			if item and item.soundPath and item.soundPath ~= "" then
				customSoundPath = item.soundPath
				playerSoundCache[player:SteamID()] = {
					sound = { soundPath = customSoundPath },
					cachedAt = CurTime()
				}
				break
			end
		end
	end
	
	if not customSoundPath then return end
	
	-- Check if this is a jihad sound to override
	-- Uses configurable patterns from module settings
	local shouldOverride = false
	
	-- Get countdown pattern from settings (default: "siege/suicide")
	local countdownPattern = Pointshop2.GetSetting( "Jihad Bomb Custom Sounds", "SoundOverride.CountdownSoundPattern" ) or "siege/suicide"
	if soundPath:find(countdownPattern) then
		shouldOverride = true
	end
	
	-- Fallback patterns for compatibility
	if not shouldOverride and (soundPath:find("jihad") or soundPath:find("allah")) and not soundPath:find("explosion") and not soundPath:find("explode") then
		shouldOverride = true
	end
	if not shouldOverride and (soundPath:find("countdown") or soundPath:find("beep") or soundPath:find("arm")) then
		shouldOverride = true
	end
	
	-- Check if explosion override is enabled
	local enableExplosionOverride = Pointshop2.GetSetting( "Jihad Bomb Custom Sounds", "SoundOverride.EnableExplosionOverride" ) or false
	if enableExplosionOverride then
		local explosionPattern = Pointshop2.GetSetting( "Jihad Bomb Custom Sounds", "SoundOverride.ExplosionSoundPattern" ) or "siege/big_explosion"
		if soundPath:find(explosionPattern) then
			shouldOverride = true
		end
	end
	
	if shouldOverride then
		data.SoundName = customSoundPath
		data.Volume = data.Volume or 1
		data.Pitch = data.Pitch or 100
		return true
	end
end )

if CLIENT then
	-- Add preview button to item description panel
	hook.Add( "PS2_ItemDescription_SetItemClass", "PS2_SoundPlayButton", function( panel, itemClass )
		if not itemClass or not itemClass.soundPath then return end
		if not IsValid( panel ) or not IsValid( panel.buttonsPanel ) then return end
		
		local btnContainer = vgui.Create( "DPanel", panel.buttonsPanel )
		btnContainer:DockMargin( 0, 5, 0, 0 )
		btnContainer:Dock( TOP )
		btnContainer:SetTall( 25 )
		function btnContainer:Paint() end
		
		local playBtn = vgui.Create( "DButton", btnContainer )
		playBtn:SetText( "▶ Preview Sound" )
		playBtn:Dock( FILL )
		playBtn:SetFont( panel:GetSkin().fontName )
		
		local soundPath = itemClass.soundPath or ""
		
		function playBtn.DoClick()
			if soundPath and soundPath ~= "" then
				local cleanPath = soundPath:gsub( "^sound/", "" )
				
				if not string.find( cleanPath, "/" ) then
					cleanPath = "custom_jihad/" .. cleanPath
				end
				
				local fullPath = "sound/" .. cleanPath
				if file.Exists( fullPath, "GAME" ) then
					-- Mark as preview sound BEFORE playing to prevent global broadcast
					Pointshop2.JihadIntegration.MarkAsPreviewSound( cleanPath )
					surface.PlaySound( cleanPath )
				else
					LocalPlayer():ChatPrint( "Sound file not found: " .. cleanPath )
				end
			else
				LocalPlayer():ChatPrint( "No sound available" )
			end
		end
		
		panel.buttonsPanel:InvalidateLayout()
	end )
end

KLogf( 4, "[Pointshop2 Sounds] Jihad Bomb integration loaded" )
