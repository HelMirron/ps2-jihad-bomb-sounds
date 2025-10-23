-- Shop Icon for Sound Items with animated sound waves
-- Uses configurable colors and animation from module settings

if not CLIENT then return end

local PANEL = {}

-- Helper to parse RGB string "R,G,B" to Color
local function ParseRGB(rgbString, default)
	if not rgbString then return default end
	local parts = string.Explode(",", rgbString)
	if #parts ~= 3 then return default end
	return Color(tonumber(parts[1]) or default.r, tonumber(parts[2]) or default.g, tonumber(parts[3]) or default.b, 240)
end

function PANEL:Paint(w, h)
	-- Get colors from settings
	local topColor = ParseRGB(
		Pointshop2.GetSetting("Jihad Bomb Custom Sounds", "IconDesign.GradientColorTop"),
		Color(35, 120, 200)
	)
	local bottomColor = ParseRGB(
		Pointshop2.GetSetting("Jihad Bomb Custom Sounds", "IconDesign.GradientColorBottom"),
		Color(70, 200, 255)
	)
	
	-- Get animation settings
	local animSpeed = Pointshop2.GetSetting("Jihad Bomb Custom Sounds", "IconDesign.AnimationSpeed") or 2.5
	local animIntensity = Pointshop2.GetSetting("Jihad Bomb Custom Sounds", "IconDesign.AnimationIntensity") or 0.25
	
	-- Dark background
	draw.RoundedBox(8, 0, 0, w, h, Color(10, 10, 15, 255))
	
	-- Gradient from top to bottom
	for i = 0, h do
		local t = i / h
		local r = math.floor(topColor.r + (bottomColor.r - topColor.r) * t)
		local g = math.floor(topColor.g + (bottomColor.g - topColor.g) * t)
		local b = math.floor(topColor.b + (bottomColor.b - topColor.b) * t)
		
		surface.SetDrawColor(r, g, b, 240)
		surface.DrawRect(0, i, w, 1)
	end
	
	-- Glow border
	surface.SetDrawColor(120, 220, 255, 80)
	surface.DrawOutlinedRect(1, 1, w-2, h-2, 1)
	
	local centerX = w / 2
	local centerY = h / 2
	
	-- Animated sound waves
	local time = RealTime()
	local pulse = math.sin(time * animSpeed) * animIntensity + (1 - animIntensity)
	
	surface.SetDrawColor(255, 255, 255, 220)
	
	local barWidth = math.max(5, w * 0.06)
	local spacing = math.max(10, w * 0.11)
	local startX = centerX - (barWidth * 1.5 + spacing)
	
	local barHeights = {
		h * 0.12 * pulse,
		h * 0.33,
		h * 0.22 * pulse
	}
	
	for i = 0, 2 do
		local barHeight = barHeights[i + 1]
		local barX = startX + i * (barWidth + spacing)
		
		-- Bar glow
		surface.SetDrawColor(150, 220, 255, 30 * pulse)
		surface.DrawRect(barX - 1.5, centerY - barHeight/2 - 1.5, barWidth + 3, barHeight + 3)
		
		-- Bar gradient
		for y = 0, barHeight do
			local gradientAlpha = 255 * (1 - (y / barHeight) * 0.25)
			surface.SetDrawColor(255, 255, 255, gradientAlpha)
			surface.DrawRect(barX, centerY - barHeight/2 + y, barWidth, 1)
		end
	end
	
	-- Border
	surface.SetDrawColor(255, 255, 255, 120)
	surface.DrawOutlinedRect(0, 0, w, h, 2)
end

vgui.Register("DPointshopSoundIcon", PANEL, "DPointshopItemIcon")
