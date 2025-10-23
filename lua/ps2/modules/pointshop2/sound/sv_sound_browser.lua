-- Server-Side Sound Browser
-- Manages available sounds with 60-second cache

if not SERVER then return end

local SOUND_CACHE_DURATION = 60
local soundCache = {}
local lastCacheTime = 0

-- Get available jihad sounds from local and workshop directories
function Pointshop2.GetAvailableJihadSounds()
	local now = CurTime()
	
	if now - lastCacheTime < SOUND_CACHE_DURATION and #soundCache > 0 then
		return soundCache
	end
	
	soundCache = {}
	
	-- Local sounds from sound/custom_jihad/
	local files = file.Find( "sound/custom_jihad/*", "GAME" )
	if files then
		for _, fileName in ipairs( files ) do
			if string.EndsWith( fileName, ".wav" ) or string.EndsWith( fileName, ".mp3" ) then
				local relativePath = "custom_jihad/" .. fileName
				local fullPath = "sound/" .. relativePath
				local fileSize = file.Size( fullPath, "GAME" ) or 0
				
				if fileSize > 0 and fileSize <= 10 * 1024 * 1024 then
					table.insert( soundCache, {
						name = fileName,
						path = relativePath,
						size = fileSize,
						source = "local"
					} )
				end
			end
		end
	end
	
	-- Workshop addon sounds
	local addonDirs = file.Find( "addons/*/", "GAME" )
	if addonDirs then
		for _, addonName in ipairs( addonDirs ) do
			local soundDir = "addons/" .. addonName .. "/sound/custom_jihad/"
			local soundFiles = file.Find( soundDir .. "*", "GAME" )
			
			if soundFiles then
				for _, fileName in ipairs( soundFiles ) do
					if string.EndsWith( fileName, ".wav" ) or string.EndsWith( fileName, ".mp3" ) then
						local relativePath = "custom_jihad/" .. fileName
						local fullPath = soundDir .. fileName
						local fileSize = file.Size( fullPath, "GAME" ) or 0
						
						if fileSize > 0 and fileSize <= 10 * 1024 * 1024 then
							local alreadyExists = false
							for _, existingSound in ipairs( soundCache ) do
								if existingSound.name == fileName then
									alreadyExists = true
									break
								end
							end
							
							if not alreadyExists then
								table.insert( soundCache, {
									name = fileName,
									path = relativePath,
									size = fileSize,
									source = "workshop_" .. addonName
								} )
							end
						end
					end
				end
			end
		end
	end
	
	lastCacheTime = now
	return soundCache
end

-- Validate sound file exists and is valid
function Pointshop2.ValidateJihadSound( soundPath )
	if not soundPath or soundPath == "" then
		return false, "Sound path is empty"
	end
	
	local fullPath = soundPath
	if not string.StartsWith( soundPath, "sound/" ) then
		fullPath = "sound/" .. soundPath
	end
	
	if not file.Exists( fullPath, "GAME" ) then
		return false, "Sound file does not exist: " .. fullPath
	end
	
	if not ( string.EndsWith( soundPath, ".wav" ) or string.EndsWith( soundPath, ".mp3" ) ) then
		return false, "Only WAV and MP3 formats are supported"
	end
	
	local fileSize = file.Size( fullPath, "GAME" ) or 0
	if fileSize == 0 or fileSize > 10 * 1024 * 1024 then
		return false, "File size must be between 1 byte and 10 MB"
	end
	
	return true
end

-- Get sound by name
function Pointshop2.GetJihadSoundByName( soundName )
	local sounds = Pointshop2.GetAvailableJihadSounds()
	for _, sound in ipairs( sounds ) do
		if sound.name == soundName then
			return sound
		end
	end
	return nil
end

-- Refresh sound cache
function Pointshop2.RefreshSoundCache()
	lastCacheTime = 0
	soundCache = {}
	Pointshop2.GetAvailableJihadSounds()
end

-- Import sounds on startup
timer.Simple( 2, function()
	Pointshop2.GetAvailableJihadSounds()
end )

-- Network handlers
util.AddNetworkString( "PS2_RequestSoundList" )
util.AddNetworkString( "PS2_SendSoundList" )

net.Receive( "PS2_RequestSoundList", function( len, ply )
	if not IsValid( ply ) or not ply:IsAdmin() then
		return
	end
	
	local sounds = Pointshop2.GetAvailableJihadSounds()
	net.Start( "PS2_SendSoundList" )
	net.WriteTable( sounds )
	net.Send( ply )
end )
