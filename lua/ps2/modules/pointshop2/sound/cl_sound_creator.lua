-- Jihad Bomb Sound Item Creator
-- Inherits from DItemCreator (Pointshop2 standard item creator)

if not CLIENT then return end

local PANEL = {}

function PANEL:Init()
	self:addSectionTitle( "Sound Selection" )
	
	self.soundDropdown = vgui.Create( "DComboBox" )
	self.soundDropdown:SetTall( 25 )
	self.soundDropdown:SetWide( self:GetWide() - 20 )
	self.soundDropdown:AddChoice( "-- Select a sound --", "" )
	
	self:LoadAvailableSounds()
	self:addFormItem( "Sound File", self.soundDropdown )
end

function PANEL:LoadAvailableSounds()
	local dropdown = self.soundDropdown
	
	net.Start( "PS2_RequestSoundList" )
	net.SendToServer()
	
	net.Receive( "PS2_SendSoundList", function( len )
		local sounds = net.ReadTable()
		if IsValid( dropdown ) then
			dropdown:Clear()
			dropdown:AddChoice( "-- Select a sound --", "" )
			for _, sound in ipairs( sounds ) do
				dropdown:AddChoice( sound.name, sound.path )
			end
		end
	end )
end

function PANEL:SaveItem( saveTable )
	self.BaseClass.SaveItem( self, saveTable )
	
	-- Remove objects to prevent circular references
	saveTable.ItemPersistence = nil
	saveTable.item = nil
	saveTable.persistence = nil
	
	-- Get selected sound path
	local soundPath = self.soundDropdown:GetValue()
	
	if soundPath == "" or not soundPath then
		KLogf( 2, "[Pointshop2 Sounds] No sound selected!" )
		return false
	end
	
	-- Remove "sound/" prefix if present
	soundPath = tostring( soundPath ):gsub( "^sound/", "" )
	
	-- Ensure path includes directory
	if not string.find( soundPath, "/" ) then
		soundPath = "custom_jihad/" .. soundPath
	end
	
	saveTable.soundPath = soundPath
	return true
end

function PANEL:EditItem( persistence, itemClass )
	self.BaseClass.EditItem( self, persistence.ItemPersistence, itemClass )
	
	if persistence.soundPath then
		self.soundDropdown:SetValue( persistence.soundPath )
	end
end

vgui.Register( "DSoundCreator", PANEL, "DItemCreator" )
