-- Jihad Bomb Sound System - Settings Configurator
-- Must inherit from DSettingsEditor and implement Configurator interface

if not CLIENT then return end

local PANEL = {}

function PANEL:Init()
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetTitle( "Jihad Bomb Sound Settings" )
	self:SetSize( 600, 500 )
	
	-- Automatically add all settings with appropriate controls
	self:AutoAddSettingsTable( Pointshop2.GetModule( "Jihad Bomb Custom Sounds" ).Settings.Shared, self )
	
	-- Add info panel at top
	local infoPanel = vgui.Create( "DInfoPanel", self )
	infoPanel:Dock( TOP )
	infoPanel:DockMargin( 5, 5, 5, 10 )
	infoPanel:SetSmall( true )
	infoPanel:SetInfo( "Configuration",
[[Customize sound patterns and icon design.
All changes are saved to database automatically.

Quick Access:
• Management → Items → Create Item (for sound items)
• Sound Directory: garrysmod/sound/custom_jihad/
]] )
	infoPanel:MoveToFront()
end

function PANEL:DoSave()
	-- Save shared settings to database
	Pointshop2View:getInstance():saveSettings( self.mod, "Shared", self.settings )
end

derma.DefineControl( "DJihadSoundConfigurator", "", PANEL, "DSettingsEditor" )
