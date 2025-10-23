-- Jihad Bomb Sound Item - Sound utility functions

local soundCache = {}

-- Get cached sound (10 minute TTL)
function Pointshop2.GetCachedJihadSound( soundName )
	if soundCache[soundName] then
		local cached = soundCache[soundName]
		if CurTime() - cached.cachedAt < 600 then
			return cached
		end
		soundCache[soundName] = nil
	end
	return nil
end

function Pointshop2.CacheJihadSound( soundName, soundPath )
	soundCache[soundName] = {
		soundPath = soundPath,
		soundName = soundName,
		cachedAt = CurTime()
	}
end

-- Cleanup cache every 5 minutes
timer.Create( "PS2_SoundItemCache", 300, 0, function()
	local now = CurTime()
	for name, data in pairs( soundCache ) do
		if now - data.cachedAt > 600 then
			soundCache[name] = nil
		end
	end
end )
