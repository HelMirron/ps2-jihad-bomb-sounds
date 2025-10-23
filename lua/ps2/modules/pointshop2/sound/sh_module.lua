-- Jihad Bomb Sound System Module Registration

local MODULE = {}

MODULE.Name = "Jihad Bomb Custom Sounds"
MODULE.Author = "Leekstreak"

-- Sound item blueprint
MODULE.Blueprints = {
	{
		label = "Jihad Bomb Sound",
		base = "base_sound",
		icon = "pointshop2/winner2.png",
		creator = "DSoundCreator"
	}
}

-- Management panel button
MODULE.SettingButtons = {
	{
		label = "Jihad Bomb Sounds",
		icon = "pointshop2/winner2.png",
		control = "DJihadSoundConfigurator"
	}
}

-- Settings
MODULE.Settings = {}
MODULE.Settings.Shared = {
	-- Sound Override Settings
	SoundOverride = {
		info = {
			label = "Sound Override Configuration"
		},
		CountdownSoundPattern = {
			value = "siege/suicide",
			type = "string",
			label = "Countdown Sound Pattern",
			tooltip = "Lua pattern to match countdown sound (e.g., 'siege/suicide' for TTT Weapon Collection)"
		},
		EnableExplosionOverride = {
			value = false,
			type = "boolean",
			label = "Override Explosion Sound",
			tooltip = "If enabled, also replaces the explosion sound (not recommended)"
		},
		ExplosionSoundPattern = {
			value = "siege/big_explosion",
			type = "string",
			label = "Explosion Sound Pattern",
			tooltip = "Lua pattern to match explosion sound (only if override enabled)"
		}
	},
	
	-- Icon Design Settings
	IconDesign = {
		info = {
			label = "Shop Icon Design"
		},
		GradientColorTop = {
			value = "35,120,200",
			type = "string",
			label = "Gradient Top Color (R,G,B)",
			tooltip = "RGB values for top gradient color (e.g., '35,120,200')"
		},
		GradientColorBottom = {
			value = "70,200,255",
			type = "string",
			label = "Gradient Bottom Color (R,G,B)",
			tooltip = "RGB values for bottom gradient color (e.g., '70,200,255')"
		},
		AnimationSpeed = {
			value = 2.5,
			type = "number",
			label = "Animation Speed",
			tooltip = "Speed of sound wave pulsing animation (2.5 = default)"
		},
		AnimationIntensity = {
			value = 0.25,
			type = "number",
			label = "Animation Intensity",
			tooltip = "Intensity of pulsing effect (0.25 = default)"
		}
	}
}

MODULE.Settings.Server = {}

Pointshop2.RegisterModule( MODULE )
